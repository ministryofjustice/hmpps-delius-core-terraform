#!/bin/bash
set -e
## HMPPS Terragrunt wrapper script.
## Runs Terragrunt commands in the HMPPS container, with sensible defaults and mounted config.
##
## This script takes any number of arguments and will pass them directly to Terragrunt.
##
## Example usage:
##    AWS_PROFILE=hmpps_token ENVIRONMENT=delius-test COMPONENT=vpc ./run.sh plan
##
## Environment variables are used to configure the script:
##  * ENVIRONMENT        Required. Which environment to run against, used to select Terraform
##                                 configuration from the config repository.
##  * CONFIG_LOCATION    Optional. Path to the environment configuration repository. Defaults
##                                 to ../hmpps-env-configs.
##  * COMPONENT          Optional. Sub-directory containing the Terraform code to apply.
##                                 Defaults to current directory.
##  * CONTAINER          Optional. The container to run the Terragrunt commands in. Defaults to
##                                 mojdigitalstudio/hmpps-terraform-builder-0-12.
##  * CMD                Optional. The executable to run in the container. Useful for debugging,
##                                 for example by setting to 'bash'. Defaults to terragrunt.
##
## Additionally, any environment variables prefixed with AWS_or TF_ will also be passed to the
## Terragrunt container. This enables you to set your AWS credentials/profile on the host, and
## also to pass any extra Terraform vars using TF_VAR_xxx=...
##

# Print usage if ENVIRONMENT not set:
if [ "${ENVIRONMENT}" == "" ]; then grep '^##' "${0}" && exit; fi

# Print heading items. Note CodeBuild doesn't support color/formatting
heading() { [ -n "${CODEBUILD_CI}" ] && echo -e "\n* ${*}" || echo -e "\n\033[1m${*}\033[0m"; }

# Start container with mounted config:
if [ -z "${TF_IN_AUTOMATION}" ]; then

  if [ -z "${CONFIG_LOCATION}" ]; then
    heading No config provided. Using defaults...
    if [ "${ENVIRONMENT}" == "dev" ]; then CONFIG_LOCATION="$(pwd)/../hmpps-engineering-platform-terraform"
                                      else CONFIG_LOCATION="$(pwd)/../hmpps-env-configs"; fi
    if [ -d "${CONFIG_LOCATION}" ];   then echo "Mounting config from ${CONFIG_LOCATION}";
                                      else (echo "Couldn't find config at ${CONFIG_LOCATION}" && exit 1); fi
  fi

  heading Starting container...
  CONTAINER=${CONTAINER:-mojdigitalstudio/hmpps-terraform-builder-0-12}
  echo "${CONTAINER}"
  docker run -e "COMPONENT=${COMPONENT}" -e "ENVIRONMENT=${ENVIRONMENT}" -e "CMD=${CMD}" \
    "$(test -t 0 && echo '-it')"                            `# Allocate an interactive terminal if one is available` \
    --env-file <(env | grep '^AWS_')                        `# Pass any environment variables prefixed with 'AWS_'` \
    --env-file <(env | grep '^TF_')                         `# Pass any environment variables prefixed with 'TF_'` \
    -e "GITHUB_TOKEN=${GITHUB_TOKEN}"                       `# Pass GitHub token, in case we need to create CodeBuild resources` \
    -e "TF_IN_AUTOMATION=True"                              `# This flag is used by Terraform to indicate a script run` \
    -e "TF_PLUGIN_CACHE_DIR=/home/tools/.terraform/plugins" `# Enable caching of Terraform plugins on host` \
    -v "${TF_PLUGIN_CACHE_DIR:-"$(pwd)/${COMPONENT}/.terraform/plugins"}:/home/tools/.terraform/plugins" \
    -v "${HOME}/.aws:/home/tools/.aws:ro"                   `# Mount the hosts AWS config files` \
    -v "$(pwd):/home/tools/data"                            `# Mount the Terraform code` \
    -v "${CONFIG_LOCATION}:/home/tools/data/env_configs:ro" `# Mount the Terraform config` \
    -v "$(cd "${0%/*}" && pwd):/home/tools/util:ro"         `# Mount the current script` \
  "${CONTAINER}" bash -c "/home/tools/util/${0##*/} ${*}"    # Re-run the current script in the container
  exit $?
fi

heading Parsing arguments...
action=${*}
options=""
if [ -n "${CODEBUILD_CI}" ];   then options="${options} -no-color"; fi
if [ "${action}" == "apply" ]; then options="${options} .terraform/out/${ENVIRONMENT}.plan"; fi
if [ "${action}" == "plan" ];  then
  if [[ "$(terraform -version)" != *0.11* ]]; then options="${options} -compact-warnings"; fi # this option is not available in Terraform 11
  options="${options} -detailed-exitcode -out .terraform/out/${ENVIRONMENT}.plan"
fi
echo "Environment: ${ENVIRONMENT:--}"
echo "Component:   ${COMPONENT:--}"
echo "Command:     ${action} ${options}"

heading Loading configuration...
test -f "env_configs/${ENVIRONMENT}/${ENVIRONMENT}.properties" && source "env_configs/${ENVIRONMENT}/${ENVIRONMENT}.properties"
test -f "env_configs/env_configs/${ENVIRONMENT}.properties" && source "env_configs/env_configs/${ENVIRONMENT}.properties"
export TERRAGRUNT_IAM_ROLE="${TERRAGRUNT_IAM_ROLE/admin/terraform}"
echo "Loaded $(env | grep -Ec '^(TF|TG)') properties"

heading Setting up workspace...
cd "${COMPONENT}"
mkdir -p ./.terraform/out
rm -rf ./.terraform/terraform.tfstate
pwd

heading Running terragrunt...
set -o pipefail
set -x
${CMD:-terragrunt} ${action} ${options} | tee ".terraform/out/${ENVIRONMENT}.tg.log"