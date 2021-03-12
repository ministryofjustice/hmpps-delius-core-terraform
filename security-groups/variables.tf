variable "environment_name" {
  type = string
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
  type        = map(string)
  description = "Map of the ports that the weblogic domains use"
}

variable "spg_partnergateway_domain_ports" {
  type        = map(string)
  description = "Map of the ports that the weblogic domains use"
}

variable "ldap_ports" {
  type        = map(string)
  description = "Map of the ports that the ldap ports"
}

variable "internal_moj_access_cidr_blocks" {
  description = "CIDRs for access via internal MOJ networks / VPNs"
  type        = list(string)
}

variable "user_access_cidr_blocks" {
  description = "CIDRS for access via public/user network"
  type        = list(string)
}

variable "env_user_access_cidr_blocks" {
  description = "Environment-specific CIDRS for access via public/user network"
  type        = list(string)
}

variable "jenkins_access_cidr_blocks" {
  description = "CIDRS for Jenkins to access"
  type        = list(string)
}

variable "tags" {
  type = map(string)
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
  type        = map(string)
  description = "Engineering remote state and arn for Oracle OPs security groups"
}

variable "azure_community_proxy_source" {
  description = "Allowed ingress CIDRs from Azure community Proxy"
  type        = list(string)
  default     = []
}

variable "azure_oasys_proxy_source" {
  description = "Allowed ingress CIDRs from Azure OASys Proxy"
  type        = list(string)
  default     = []
}

variable "ci_db_ingress_1521" {
  description = "Enable sg rule for ingress to port 1521 from CI eg Jenkins/AWS CodePipeline"
  default     = false
}

