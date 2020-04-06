variable "environment_name" {
  type = "string"
}

variable "short_environment_name" {
  type = "string"
}

variable "project_name" {
  description = "The project name - delius-core"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "ldap_ports" {
  type        = "map"
  description = "Map of the ports that the ldap ports"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "default_ldap_config" {
  description = "Default LDAP configuration. Overridden by ldap_config."
  type        = "map"
}

variable "ldap_config" {
  description = "LDAP configuration"
  type        = "map"
}

variable "tags" {
  type = "map"
}
