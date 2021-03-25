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

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "common_ecs_scaling_config" {
  description = "Default scaling configuration for ECS services. Can be overridden per-application or per-environment in the environment configuration repository (hmpps-env-configs)."
  type        = map(string)
}

variable "aptracker_api_config" {
  description = "Application-specific configuration items"
  type        = map(string)
}

variable "default_aptracker_api_config" {
  description = "Default values to be overridden by aptracker_api_config"
  type        = map(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

