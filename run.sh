#!/bin/bash
set -e
## HMPPS Terragrunt wrapper script.
## This script takes any number of arguments and will pass them to Terragrunt.
##
## Example usage:
##    AWS_PROFILE=hmpps ENVIRONMENT=delius-test COMPONENT=vpc ./run.sh plan
##
##
## Environment variables are used to configure the script:
##  * ENVIRONMENT        Required. Which environment to run against, used to select Terraform
##                                 configuration from the config repository.
##  * CONFIG_LOCATION    Optional. Path to the environment configuration directory. Defaults
##                                 to ../hmpps-env-configs.
##  * COMPONENT          Optional. Sub-directory containing the Terraform code to apply.
##                                 Defaults to current directory.
##  * CONTAINER          Optional. The container to run the Terragrunt commands in. Defaults to
##                                 mojdigitalstudio/hmpps-terraform-builder-0-12.
## Any environment variables prefixed with AWS_ will also be passed to the Terragrunt container.
##
##
## The following shows a convenient way of temporarily set env vars once for multiple terragrunt
## commands:
##    AWS_PROFILE=hmpps ENVIRONMENT=delius-test COMPONENT=vpc ${SHELL}
##     ./run.sh plan -out tfplan
##     ./run.sh apply tfplan
##     ...
##    Then press Ctrl+D to reset env vars

# Print usage if ENVIRONMENT not set:
if [ "${ENVIRONMENT}" == "" ]; then grep '^##' "${0}" && exit; fi

# Print heading items. Note CodeBuild doesn't support color/formatting
heading() { [ -n "${CODEBUILD_CI}" ] && echo "${*}" || echo -e "\n\033[1m${*}\033[0m"; }

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
  aws_env="$(env | grep ^AWS_ | sed 's/^/-e /')"
  docker run \
    ${aws_env} \
    -e "COMPONENT=${COMPONENT}" \
    -e "ENVIRONMENT=${ENVIRONMENT}" \
    -e "GITHUB_TOKEN=${GITHUB_TOKEN}" \
    -e TF_IN_AUTOMATION=True \
    -v "${HOME}/.aws:/home/tools/.aws:ro" \
    -v "$(pwd):/home/tools/data" \
    -v "${CONFIG_LOCATION}:/home/tools/data/env_configs:ro" \
  "${CONTAINER}" bash -c "${0} ${*}"
  exit $?
fi

heading Parsing arguments...
action=${*}
options=""
if [ -n "${CODEBUILD_CI}" ];        then options="${options} -no-color"; fi
if [ "${action}" == "plan" ];       then options="${options} -detailed-exitcode -compact-warnings -out ${ENVIRONMENT}.plan"; fi
if [ "${action}" == "apply" ];      then options="${options} ${ENVIRONMENT}.plan"; fi
echo "Environment: ${ENVIRONMENT:--}"
echo "Component:   ${COMPONENT:--}"
echo "Command:     ${action}"

heading Loading configuration...
test -f "env_configs/${ENVIRONMENT}/${ENVIRONMENT}.properties" && source "env_configs/${ENVIRONMENT}/${ENVIRONMENT}.properties"
test -f "env_configs/env_configs/${ENVIRONMENT}.properties" && source "env_configs/env_configs/${ENVIRONMENT}.properties"
export TERRAGRUNT_IAM_ROLE="${TERRAGRUNT_IAM_ROLE/admin/terraform}"
echo "Loaded $(env | grep -Ec '^(TF|TG)') properties"

heading Setting up workspace...
cd "${COMPONENT}"
rm -rf ./.terraform/terraform.tfstate
pwd

heading Running terragrunt...
set -o pipefail
set -x
terragrunt ${action} ${options} | tee "${ENVIRONMENT}.plan.log"