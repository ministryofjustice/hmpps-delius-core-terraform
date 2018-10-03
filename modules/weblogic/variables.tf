variable "admin_instance_type" {
  description = "Instance type for the admin server"
  type        = "string"
}

variable "managed_instance_type" {
  description = "Instance type for the managed server"
  type        = "string"
}

variable "admin_security_groups" {
  description = "Security groups for the admin server"
  type        = "list"
}

variable "managed_security_groups" {
  description = "Security groups for the managed server"
  type        = "list"
}

variable "private_subnet" {
  description = "Subnet for the servers"
  type        = "string"
}

variable "public_subnets" {
  description = "Subnet for load balancers"
  type        = "list"
}

variable "tags" {
  description = "Tags to match tagging standard"
  type        = "map"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = "string"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "managed_elb_sg_id" {
  description = "ID for the security group for the ELB"
  type        = "string"
}

variable "admin_elb_sg_id" {
  description = "ID for the security group for the ELB"
  type        = "string"
}

variable "managed_port" {
  description = "TCP port for the managed server"
  type        = "string"
}

variable "admin_port" {
  description = "TCP port for the admin server"
  type        = "string"
}

variable "tier_name" {
  description = "Name of the Weblogic tier"
  type        = "string"
}
# TODO use one of "vpc_id" or "vpc_account_id"
variable "vpc_id" {
  description = "VPC ID"
  type        = "string"
}

variable "vpc_account_id" {
  description = "VPC Account ID"
  type        = "string"
}

variable "key_name" {
  description = "Deployer key name"
  type        = "string"
}

variable "kms_key_id" {
  description = "ARN of KMS Key"
  type        = "string"
}

variable "public_zone_id" {
  description = "Public zone id"
  type        = "string"
}

variable "private_zone_id" {
  description = "Private internal zone id"
  type        = "string"
}

variable "private_domain" {
  description = "Private internal zone name"
  type        = "string"
}

variable "ami_id" {
  description = "AWS AMI ID"
  type        = "string"
}

variable "iam_instance_profile" {
  description = "iam instance profile id"
  type        = "string"
}
