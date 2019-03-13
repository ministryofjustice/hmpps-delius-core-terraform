variable "environment_name" {
  type = "string"
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

variable "weblogic_domain_ports" {
  type        = "map"
  description = "Map of the ports that the weblogic domains use"
}

variable "spg_partnergateway_domain_ports" {
  type        = "map"
  description = "Map of the ports that the weblogic domains use"
}


variable "ldap_ports" {
  type        = "map"
  description = "Map of the ports that the ldap ports"
}

variable "egress_80" {
  description = "Enable sg rule for egress to port 80"
  default     = false
}

variable "egress_443" {
  description = "Enable sg rule for egress to port 433"
  default     = false
}

variable "vpc_supernet" {
  description = "VPC CIDR"
}

variable "user_access_cidr_blocks" {
  description = "CIDRS for access via public/user network"
  type        = "list"
}

variable "env_user_access_cidr_blocks" {
  description = "Environment-specific CIDRS for access via public/user network"
  type        = "list"
}

variable "jenkins_access_cidr_blocks" {
  description = "CIDRS for Jenkins to access"
  type        = "list"
}

variable "tags" {
  type = "map"
}
