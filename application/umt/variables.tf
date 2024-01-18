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

variable "umt_config" {
  description = "Application-specific configuration items"
  type        = map(string)
}

variable "default_umt_config" {
  description = "Default values to be overridden by umt_config"
  type        = map(string)
}

variable "ldap_config" {
  description = "LDAP configuration"
  type        = map(string)
}

variable "default_ldap_config" {
  description = "Default values to be overridden by ldap_config"
  type        = map(string)
}

variable "default_delius_app_config" {
  description = "Default Delius application configuration items, to be overridden by delius_app_config"
  type        = map(string)
}

variable "delius_app_config" {
  description = "Delius application configuration items"
  type        = map(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "dual_run_with_sr28" {
  description = "Temporary variable to determine whether the environment is dual-running SR28 and SR29. Will be removed once SR29 is live."
  type        = bool
  default     = false
}
