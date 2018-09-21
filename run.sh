#!/usr/bin/env bash

set -e

#Usage
# Scripts takes four (4) arguments:
# 1) environment_name : eg same as the env's config file name delius-core-dev delius-perf alfresco-dev
# 2) action | ACTION_TYPE: task to complete example plan apply test clean
# 3) component | eg vpc security-groups application (name of subdir where resources are defined in Terraform)
# 4*) optional AWS_TOKEN: token to use when running locally eg hmpps-token

# Error handler function
exit_on_error() {
  exit_code=$1
  last_command=${@:2}
  if [ $exit_code -ne 0 ]; then
      >&2 echo "\"${last_command}\" command failed with exit code ${exit_code}."
      exit ${exit_code}
  fi
}

cleanUp() {
  echo "cleanUp"
  echo "${ENVIRONMENT_NAME}"
  if [[ -f "${tfstate}" ]]
  then
    if grep --quiet "${ENVIRONMENT_NAME}" "${tfstate}"
    then
      echo "state for env"
    else
      echo "not state for env - cleaning up"
      rm -rf "${baseDir}/${COMPONENT}/.terraform"
      sleep 5
    fi
  fi
  rm -rf ${HOME}/data/env_configs/inspec.properties
}

ENVIRONMENT_NAME=${1}
ACTION_TYPE=${2}
COMPONENT=${3}
AWS_TOKEN=${4}

baseDir=$(pwd)
env_config_dir="${baseDir}/env_configs"
tfstate="${baseDir}/${COMPONENT}/.terraform/terraform.tfstate"



if [ -z "${ENVIRONMENT_NAME}" ]
then
    echo "ENVIRONMENT_NAME argument not supplied, please provide an argument!"
    exit 1
fi

echo "Output -> ENVIRONMENT_NAME set to: ${ENVIRONMENT_NAME}"

if [ -z "${ACTION_TYPE}" ]
then
    echo "ACTION_TYPE argument not supplied."
    echo "--> Defaulting to plan ACTION_TYPE"
    ACTION_TYPE="plan"
fi

echo "Output -> ACTION_TYPE set to: ${ACTION_TYPE}"

if [ -z "${COMPONENT}" ]
then
    echo "COMPONENT argument not supplied."
    echo "--> Defaulting to common component"
    COMPONENT="common"
fi

if [ ! -z "${AWS_TOKEN}" ]
then
    AWS_TOKEN="${AWS_TOKEN}"
    TOKEN_ARGS="-e AWS_PROFILE=${AWS_TOKEN}"
    echo "Output -> AWS_TOKEN set to: ${AWS_TOKEN}"
    echo "Output ---> input stage complete"
fi

# Commands
tg_planCmd="terragrunt plan -detailed-exitcode --out ${ENVIRONMENT_NAME}.plan"

tg_applyCmd="terragrunt apply ${ENVIRONMENT_NAME}.plan"

runCmd="docker run -it --rm -v $(pwd):/home/tools/data \
    -v ${HOME}/.aws:/home/tools/.aws \
    ${TOKEN_ARGS} -e RUNNING_IN_CONTAINER=True hmpps/terraform-builder:latest sh run.sh ${ENVIRONMENT_NAME} ${ACTION_TYPE} ${COMPONENT}"

#check env vars for RUNNING_IN_CONTAINER switch
if [[ ${RUNNING_IN_CONTAINER} == True ]]
then
    echo "Output -> environment stage"
    source ${env_config_dir}/${ENVIRONMENT_NAME}.properties
    exit_on_error $? !!
    echo "Output ---> set environment stage complete"
    # set runCmd
    ACTION_TYPE="docker-${ACTION_TYPE}"
    cd ${COMPONENT}
    echo "Output -> Component Container working Dir: $(pwd)"
fi

case ${ACTION_TYPE} in
  plan)
    echo "Running plan action"
    cleanUp
    echo "Docker command: ${runCmd}"
    ${runCmd} plan
    exit_on_error $? !!
    ;;
  docker-plan)
    echo "Running docker plan action"
    terragrunt init
    exit_on_error $? !!
    terragrunt plan -detailed-exitcode --out ${ENVIRONMENT_NAME}.plan
    exit_on_error $? !!
    ;;
  apply)
    echo "Running apply action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} apply
    exit_on_error $? !!
    ;;
  docker-apply)
    echo "Running docker apply action"
    terragrunt apply ${ENVIRONMENT_NAME}.plan
    exit_on_error $? !!
    ;;
  destroy)
    echo "Running destroy action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} destroy
    exit_on_error $? !!
    ;;
  docker-destroy)
    echo "Running docker destroy action"
    terragrunt destroy -force
    exit_on_error $? !!
    ;;
  test)
    echo "Running test action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} test
    exit_on_error $? !!
    ;;
  docker-test)
    echo "Running docker test action"
    . "${baseDir}/scripts/generate-terraform-outputs-component.sh"
    exit_on_error $? !!
    . "${baseDir}/scripts/aws-get-temp-creds.sh"
     exit_on_error $? !!
    . "${baseDir}/env_configs/inspec-creds.properties"
    exit_on_error $? !!
    inspec exec "${inspec_profile_dir}/${COMPONENT}" -t aws://${TG_REGION}
    exit_on_error $? !!
    ;;
  output)
    echo "Running output action"
    cleanUp
    exit_on_error $? !!
    ${runCmd} output
    exit_on_error $? !!
    ;;
  docker-output)
    echo "Running docker apply action"
    terragrunt output
    exit_on_error $? !!
    ;;
  *)
    echo "${ACTION_TYPE} is not a valid argument. init - apply - test - output - destroy"
  ;;
esac
