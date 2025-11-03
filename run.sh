#!/usr/bin/env bash
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
##                                 mojdigitalstudio/hmpps-terraform-builder-0-13.
##  * CMD                Optional. The executable to run in the container. Useful for debugging,
##                                 for example by setting to 'bash'. Defaults to terragrunt.
##
## Additionally, any environment variables prefixed with AWS_or TF_ will also be passed to the
## Terragrunt container. This enables you to set your AWS credentials/profile on the host, and
## also to pass any extra Terraform vars using TF_VAR_xxx=...
##
# Temp - Delete if found
# Print usage if ENVIRONMENT not set:
if [ "${ENVIRONMENT}" == "" ]; then grep '^##' "${0}" && exit; fi

heading() { if [ -n "${CODEBUILD_CI}" ]; then echo -e "\n* ${*}"; else echo -e "\n\033[1m${*}\033[0m"; fi }
load_config() { if [ -f "$1" ]; then echo "$1"; source "$1"; fi }
config_is_local() { git config remote.origin.url | grep 'hmpps-engineering-platform-terraform\|hmpps-security-access-terraform\|hmpps-vcms-terraform\|hmpps-delius-bastion'; }
engineering_env() { [[ "${ENVIRONMENT}" == eng-* ]]; }
vcms_env() { [[ "${ENVIRONMENT}" == vcms-* ]]; }
sec_env() { [[ "${ENVIRONMENT}" == sec-* ]]; }

# Start container with mounted config:
if [ -z "${TF_IN_AUTOMATION}" ]; then

  if [ -z "${CONFIG_LOCATION}" ]; then
    heading No config provided. Using defaults...
    CONFIG_LOCATION="$(pwd)/../hmpps-env-configs"
    if   config_is_local; then CONFIG_LOCATION="$(pwd)";
    elif engineering_env; then CONFIG_LOCATION="$(pwd)/../hmpps-engineering-platform-terraform";
    elif vcms_env;        then CONFIG_LOCATION="$(pwd)/../hmpps-vcms-terraform";
    elif sec_env;         then CONFIG_LOCATION="$(pwd)/../hmpps-security-access-terraform"; fi
    if [ -d "${CONFIG_LOCATION}" ]; then echo "Mounting config from ${CONFIG_LOCATION}";
                                    else (echo "Couldn't find config at ${CONFIG_LOCATION}" && exit 1); fi
  fi

  heading Starting container...
  CONTAINER=${CONTAINER:-mojdigitalstudio/hmpps-terraform-builder-0-13}
  echo "${CONTAINER}"
  docker run -e COMPONENT -e ENVIRONMENT -e CMD -e SOURCE_REPO_URL \
    $(test -t 0 && echo '-it')                               `# Allocate an interactive terminal if one is available` \
    --env-file <(env | grep -E '^(TF_|TG_|AWS_)')            `# Pass any environment variables prefixed with TF_, TG_ or AWS_` \
    -e GITHUB_TOKEN -e "TF_VAR_github_token=${GITHUB_TOKEN}" `# Pass GitHub token, in case we need to create CodeBuild resources` \
    -e "TF_IN_AUTOMATION=True"                               `# This flag is used by Terraform to indicate a script run` \
    -e "TF_PLUGIN_CACHE_DIR=/tmp/plugin-cache"               `# Enable caching of Terraform plugins on host` \
    $(test -n "${TF_PLUGIN_CACHE_DIR}" && echo "-v ${TF_PLUGIN_CACHE_DIR}:/tmp/plugin-cache") \
    -e "CONFIG_LOCATION=/home/tools/config"                  `# Pass the Terraform config location`\
    -v "${CONFIG_LOCATION}:/home/tools/config:ro"            `# Mount the Terraform config` \
    -v "$(pwd):/home/tools/data"                             `# Mount the Terraform code` \
    -v "${HOME}/.aws:/home/tools/.aws:ro"                    `# Mount the hosts AWS config files` \
    -v "$(cd "${0%/*}" && pwd):/home/tools/util:ro"          `# Mount the current script` \
  "${CONTAINER}" bash -c "/home/tools/util/${0##*/} ${*}"     # Re-run the current script in the container
  exit $?
fi

heading Parsing arguments...
OUT_DIR=${OUT_DIR:-.terraform/output/${ENVIRONMENT}}
action=${*}
options=""
if [ -n "${CODEBUILD_CI}" ];   then options="${options} -no-color"; fi
if [ "${action}" == "apply" ]; then options="${options} ${OUT_DIR}/tfplan"; fi
if [ "${action}" == "plan" ];  then
  if [[ "$(terraform -version)" != *0.11* ]]; then options="${options} -compact-warnings"; fi # this option is not available in Terraform 11
  options="${options} -detailed-exitcode -out ${OUT_DIR}/tfplan"
fi
echo "Environment: ${ENVIRONMENT:--}"
echo "Component:   ${COMPONENT:--}"
echo "Command:     ${action} ${options}"

heading Loading configuration from ${CONFIG_LOCATION:-$(pwd)}...
[ ! -d env_configs ] && [ ! -h env_configs ] && ln -s -f "${CONFIG_LOCATION}" env_configs
load_config "${CONFIG_LOCATION:-.}/${ENVIRONMENT}/${ENVIRONMENT}.properties"        # hmpps-env-configs
load_config "${CONFIG_LOCATION:-.}/env_configs/${ENVIRONMENT}.properties"           # hmpps-security-access-terraform
load_config "${CONFIG_LOCATION:-.}/env_configs/${ENVIRONMENT/eng-/}.properties"     # hmpps-engineering-platform-terraform
load_config "${CONFIG_LOCATION:-.}/env_configs/${ENVIRONMENT/vcms-/}.properties.sh" # hmpps-vcms-terraform
load_config "${CONFIG_LOCATION:-.}/env_configs/common.properties.sh"                # hmpps-vcms-terraform/common
export TERRAGRUNT_IAM_ROLE="${TERRAGRUNT_IAM_ROLE/admin/terraform}"
[ -n "${SOURCE_REPO_URL}" ] && export TF_VAR_tags=$(echo "${TF_VAR_tags}" | sed -E "s|(source-code = )\"[^\"]*\"|\1\"${SOURCE_REPO_URL}\"|")
echo "Loaded $(env | grep -Ec '^(TF_|TG_)') properties"

heading Setting up workspace...
cd "${COMPONENT}"
mkdir -p "${OUT_DIR}"
rm -rf .terraform/terraform.tfstate
pwd

heading Running terragrunt...
set -o pipefail
set -x
${CMD:-terragrunt} ${action} ${options} | tee "${OUT_DIR}/tg.log"