#!/usr/bin/env bash
# Quick script to import existing log groups that were auto-created by ECS
# Used to support upgrade of ECS services for ALS-1555
#
# Usage:
#   ENVIRONMENT=... CMD=bash tg utility_scripts/import-log-groups.sh

cd application/aptracker-api
rm -rf .terraform/terraform.tfstate
terragrunt import -compact-warnings -input=true module.ecs_service.aws_cloudwatch_log_group.log_group[0] "${ENVIRONMENT}/delius-aptracker-api"

cd ../community-api
rm -rf .terraform/terraform.tfstate
terragrunt import -compact-warnings -input=true module.ecs.aws_cloudwatch_log_group.log_group[0] "${ENVIRONMENT}/community-api"

cd ../delius-api
rm -rf .terraform/terraform.tfstate
terragrunt import -compact-warnings -input=true module.ecs.aws_cloudwatch_log_group.log_group[0] "${ENVIRONMENT}/delius-api"

cd ../pwm
rm -rf .terraform/terraform.tfstate
terragrunt import -compact-warnings -input=true module.service.aws_cloudwatch_log_group.log_group[0] "${ENVIRONMENT}/password-reset"

cd ../umt
rm -rf .terraform/terraform.tfstate
terragrunt import -compact-warnings -input=true module.ecs.aws_cloudwatch_log_group.log_group[0] "${ENVIRONMENT}/usermanagement"
