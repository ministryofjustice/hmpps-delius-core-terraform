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

variable "weblogic_domain_ports" {
  type        = "map"
  description = "Map of the ports that the weblogic domains use"
}

variable "instance_type_weblogic" {
  description = "The ec2 instance type"
}

variable "instance_count_weblogic_ndelius" {
  description = "The desired number of weblogic instances"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "default_ansible_vars" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars"
  type        = "map"
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = "map"
}

variable "ansible_vars_apacheds" {
  description = "Ansible (ldap) vars for user_data script "
  type        = "map"
}

variable "default_ansible_vars_apacheds" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars_apacheds"
  type        = "map"
}

variable "ldap_ports" {
  type        = "map"
  description = "Map of the ports that the ldap ports"
}

variable "tags" {
  type = "map"
}

variable "delius_core_haproxy_instance_type" {
  type        = "string"
  description = "Instance type to use for the proxy servers sitting between the external and internal load-balancers"
}

variable "delius_core_haproxy_instance_count" {
  type        = "string"
  description = "Instance count to use for the proxy servers sitting between the external and internal load-balancers"
}

#### Duplicated from application/spg
# Introduce a switch variable to allow the spg jms host broker url to be specified from the remote state file which is
# generated by the AmazonMQ broker (data).
# To revert to the local.spg_jms_default_url variable, esnure spg_jms_host_src = "var" to the delius
# env-configs for an environment where there is no SPG AmazonMQ broker
variable spg_jms_host_src {
  default     = "data"
  description = "'var' results in url derived from 'local.spg_jms_default_url' | data results in url derived from  data.terraform.remote_state.amazonmq.amazon_mq_broker_connect_url"
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