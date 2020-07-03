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

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "delius_core_haproxy_instance_type" {
  type        = "string"
  description = "Instance type to use for the proxy servers sitting between the external and internal load-balancers"
}

variable "delius_core_haproxy_instance_count" {
  type        = "string"
  description = "Instance count to use for the proxy servers sitting between the external and internal load-balancers"
}

variable "default_pwm_config" {
  description = "Application-specific configuration items"
  type        = "map"
  default     = {}
}

variable "pwm_config" {
  description = "Application-specific configuration items"
  type        = "map"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}

variable "aws_nameserver" {
  description = "IP of the VPC DNS resolver"
  type        = "string"
}

variable "delius_core_public_zone" {
  description = "Whether to use the 'strategic' domain (gov.uk), or the 'legacy' domain (dsd.io) for user-facing services in this environment eg. NDelius, PWM"
  type        = "string"
  default     = "strategic"
}
