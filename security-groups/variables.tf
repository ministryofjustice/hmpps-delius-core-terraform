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

variable "eng_remote_state_bucket_name" {
  description = "Engineering remote state bucket name"
}

variable "eng_role_arn" {
  description = "arn to use for engineering platform terraform"
}

variable "bastion_remote_state_bucket_name" {
  description = "Terraform remote state bucket name for bastion vpc"
}

variable "bastion_role_arn" {
  description = "arn to use for bastion terraform"
}

variable "oracle_db_operation" {
  type        = "map"
  description = "Engineering remote state and arn for Oracle OPs security groups"
}

variable "azure_community_proxy_source" {
  description = "Allowed ingress CIDRs from Azure community Proxy"
  type        = "list"
  default     = []
}

variable "azure_oasys_proxy_source" {
  description = "Allowed ingress CIDRs from Azure OASys Proxy"
  type        = "list"
  default     = []
}

variable "ci_db_ingress_1521" {
  description = "Enable sg rule for ingress to port 1521 from CI eg Jenkins/AWS CodePipeline"
  default     = false
}
