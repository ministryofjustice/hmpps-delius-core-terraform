variable "region" {}
variable "environment_name" {}
variable "short_environment_name" {}
variable "project_name" {}
variable "remote_state_bucket_name" {}

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

variable "app_name" {
  description = "Service name"
  type        = string
}

variable "dns_name" {
  description = "The first part of the DNS name to create in Route53 e.g. ndelius"
  type        = string
}

variable "app_config" {
  description = "Application-specific configuration items"
  type        = map(string)
}

variable "security_groups_lb" {
  description = "Security Groups to apply to the Application Load Balancer"
  type        = list(string)
  default     = []
}

variable "security_groups_instances" {
  description = "Security Groups to apply to the ECS instances"
  type        = list(string)
  default     = []
}

variable "enable_response_time_alarms" {
  description = "Enable or disable standard alarms for response times."
  default     = true
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "health_check_path" {
  default = "/NDelius-war/delius/JSP/healthcheck.jsp?ping"
}

variable "health_check_matcher" {
  default = 200
}