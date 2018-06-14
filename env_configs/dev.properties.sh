#!/usr/bin/env bash

# AWS ROLE ARN
# AWS subaccount 723123699647 delius-core-non-prod
export TERRAGRUNT_IAM_ROLE="arn:aws:iam::723123699647:role/admin"

## GENERIC VARIABLES

# AWS-REGION
export TG_REGION="eu-west-2"

# BUSINESS_UNIT
export TG_BUSINESS_UNIT="hmpps"

# PROJECT
export TG_PROJECT="delius-core"

# ENVIRONMENT
export TG_ENVIRONMENT_TYPE="dev"

## TERRAGUNT VARIABLES

export TG_ENVIRONMENT_IDENTIFIER="tf-${TG_REGION}-hmpps-vcms-${TG_ENVIRONMENT_TYPE}"

# REMOTE_STATE_BUCKET
export TG_REMOTE_STATE_BUCKET="${TG_ENVIRONMENT_IDENTIFIER}-remote-state"

# ###################
# TERRAFORM VARIABLES
# ###################

export TF_VAR_environment_type=${TG_ENVIRONMENT_TYPE}
export TF_VAR_region=${TG_REGION}
