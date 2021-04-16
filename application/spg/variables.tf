variable "environment_name" {
  type = string
}

variable "short_environment_name" {
  type = string
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

variable "weblogic_domain_ports" {
  type        = map(string)
  description = "Map of the ports that the weblogic domains use"
}

variable "instance_type_activemq" {
  description = "The ec2 instance type"
}

variable "instance_count_weblogic_spg" {
  description = "The desired number of weblogic instances"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "default_ansible_vars" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars"
  type        = map(string)
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = map(string)
}

variable "default_activemq_config" {
  description = "Default ActiveMQ configuration"
  type        = map(string)
}

variable "activemq_config" {
  description = "ActiveMQ configuration"
  type        = map(string)
}

variable "ldap_ports" {
  type        = map(string)
  description = "Map of the ports that the ldap ports"
}

variable "tags" {
  type = map(string)
}

