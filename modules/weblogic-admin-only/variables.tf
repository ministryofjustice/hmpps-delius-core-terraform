variable "tier_name" {
  description = "Name of the Weblogic tier"
  type        = string
}

variable "ami_id" {
  description = "AWS AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the weblogic server"
  type        = string
}

variable "instance_count" {
  description = "Instance count for the weblogic auto-scaling group"
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

variable "instance_security_groups" {
  description = "Security groups for the WebLogic instances"
  type        = list(string)
}

variable "lb_security_groups" {
  description = "Security groups for the application load balancer"
  type        = list(string)
}

variable "public_subnets" {
  description = "Subnet for Managed load balancers"
  type        = list(string)
}

variable "private_subnets" {
  description = "Subnet for Admin load balancers"
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

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
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

variable "certificate_arn" {
  description = "SSL certificate to be used for the external LB"
  type        = string
}

variable "weblogic_port" {
  description = "Port for the weblogic admin server"
  type        = string
}

variable "weblogic_health_check_path" {
  description = "parameters for the LB health check"
  type        = string
}

variable "app_bootstrap_src" {
  description = "app bootstrap src"
  type        = string
}

variable "app_bootstrap_version" {
  description = "app bootstrap version"
  type        = string
}

variable "app_bootstrap_roles" {
  description = "list of names of the Ansible Galaxy roles to apply during bootstrap"
  type        = list(string)
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = map(string)
}

variable "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic that should receive CloudWatch alarm notifications"
  type        = string
}

