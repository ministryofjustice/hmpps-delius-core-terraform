#!/usr/bin/env bash

cd application/aptracker-api
terragrunt import -compact-warnings -input=true module.ecs_service.aws_cloudwatch_log_group.log_group "${ENVIRONMENT}/delius-aptracker-api"
cd ../community-api
terragrunt import -compact-warnings -input=true module.ecs.aws_cloudwatch_log_group.log_group "${ENVIRONMENT}/community-api"
cd ../delius-api
terragrunt import -compact-warnings -input=true module.ecs.aws_cloudwatch_log_group.log_group "${ENVIRONMENT}/delius-api"
cd ../pwm
terragrunt import -compact-warnings -input=true module.service.aws_cloudwatch_log_group.log_group "${ENVIRONMENT}/password-reset"