variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_name" {
  description = "Environment name to be used as a unique identifier for resources - eg. delius-core-dev"
}

variable "short_environment_name" {
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - eg. dlc-dev"
}

variable "environment_type" {
  description = "Environment type to be used as a unique identifier for resources - eg. dev or pre-prod"
}

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "common_ecs_scaling_config" {
  description = "Default scaling configuration for ECS services. Can be overridden per-application or per-environment in the environment configuration repository (hmpps-env-configs)."
  type        = map(string)
}

variable "merge_config" {
  description = "Application-specific configuration items"
  type        = map(string)
  default = {
    # Defaults are below. Keeping these as separate variables allows us to override specific config keys
    # without having to rewrite the entire map, by using the merge() function. See locals.tf.
  }
}

variable "default_merge_config" {
  description = "Default values to be overridden by merge_config. This should match the intended config for production."
  type        = map(string)
  default = {
    # See https://github.com/ministryofjustice/hmpps-env-configs/blob/master/common/common.tfvars
    #     https://github.com/ministryofjustice/hmpps-env-configs/blob/master/common/common-prod.tfvars
  }
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

