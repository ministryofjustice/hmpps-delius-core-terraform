variable "tier_name" {
  description = "Name of the Weblogic tier"
  type        = string
}

variable "key_name" {
  description = "Deployer key name"
  type        = string
}

variable "iam_instance_profile" {
  description = "iam instance profile id"
  type        = string
}

variable "eip_allocation_ids" {
  description = "Elastic IP addresses to assign to the external load balancer"
  type        = list(string)
}

variable "public_subnets" {
  description = "Subnet for external load balancer"
  type        = list(string)
}

variable "private_subnets" {
  description = "Subnet for HAProxy ASG"
  type        = list(string)
}

variable "tags" {
  description = "Tags to match tagging standard"
  type        = map(string)
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "short_environment_name" {
  description = "Shortend name of the environment"
  type        = string
}

variable "bastion_inventory" {
  description = "Bastion environment inventory"
  type        = string
}

variable "project_name" {
  description = "The project name - eg. delius-core"
  type        = string
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

variable "region" {
  description = "The AWS region."
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_account_id" {
  description = "VPC Account ID"
  type        = string
}

variable "public_zone_id" {
  description = "Public zone id"
  type        = string
}

variable "private_zone_id" {
  description = "Private internal zone id"
  type        = string
}

variable "private_domain" {
  description = "Private internal zone name"
  type        = string
}

variable "alb_fqdn" {
  description = "DNS name of the ALB to forward traffic to"
  type        = string
}

variable "aws_nameserver" {
  description = "IP of the VPC DNS resolver"
  type        = string
}

variable "haproxy_instance_type" {
  description = "Instance type to use for the HAProxy instances"
  type        = string
}

variable "haproxy_instance_count" {
  description = "Instance count to use for the HAProxy instances"
  type        = string
}

variable "haproxy_security_groups" {
  description = "Security groups to apply to the HAProxy instances"
  type        = list(string)
}

variable "access_logs_bucket_name" {
  description = "Name of the S3 bucket used for storing Load Balancer access logs"
  type        = string
}

variable "enabled" {
    description = "Enable or disable the deployment"
    type        = bool
}
