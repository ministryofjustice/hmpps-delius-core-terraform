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

variable "umt_config" {
  description = "Application-specific configuration items"
  type = "map"
}

variable "default_umt_config" {
  description = "Default values to be overridden by umt_config"
  type = "map"
}

variable "ldap_config" {
  description = "LDAP configuration"
  type = "map"
}

variable "default_ldap_config" {
  description = "Default values to be overridden by ldap_config"
  type = "map"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}

variable "default_ansible_vars" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars"
  type        = "map"
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = "map"
}