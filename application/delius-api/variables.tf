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
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - eg. load balancers, target groups"
}

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "delius_core_public_zone" {
  description = "Whether to use the 'strategic' domain (Terraform-managed), or the 'legacy' domain (Ansible-managed) for user-facing services in this environment eg. NDelius, PWM"
  default     = "strategic"
  # NOTE:
  # This is only in place to support transition from the old public zone (dsd.io) to the strategic public zone (gov.uk).
  # It allows us to configure which zone to use for public-facing services (eg. NDelius, PWM) on a per-environment
  # basis. Currently only Prod and Pre-Prod should use the old public zone, once they are transitioned over we should
  # remove this. Additionally, there are a few services that have DNS records in the public zone that should be moved
  # over into the private zone before we complete the transition eg. delius-db-1, management.
}

variable "common_ecs_scaling_config" {
  description = "Default scaling configuration for ECS services. Can be overridden per-application or per-environment in the environment configuration repository (hmpps-env-configs)."
  type        = map(string)
}

variable "default_delius_api_config" {
  description = "Application-specific configuration items"
  type        = map(string)
  default     = {}
}

variable "delius_api_config" {
  description = "Application-specific configuration items"
  type        = map(string)
}

variable "delius_api_environment" {
  description = "Application-specific environment variables"
  type        = map(string)
  default     = {}
}

variable "delius_api_secrets" {
  description = "Application-specific secrets"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

