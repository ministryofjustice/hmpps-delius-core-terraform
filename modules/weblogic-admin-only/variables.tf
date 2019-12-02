variable "tier_name" {
  description = "Name of the Weblogic tier"
  type        = "string"
}

variable "ami_id" {
  description = "AWS AMI ID"
  type        = "string"
}

variable "instance_type" {
  description = "Instance type for the weblogic server"
  type        = "string"
}

variable "instance_count" {
  description = "Instance count for the weblogic auto-scaling group"
  type        = "string"
}

variable "key_name" {
  description = "Deployer key name"
  type        = "string"
}

variable "iam_instance_profile" {
  description = "iam instance profile id"
  type        = "string"
}

variable "instance_security_groups" {
  description = "Security groups for the WebLogic instances"
  type        = "list"
}

variable "lb_security_groups" {
  description = "Security groups for the application load balancer"
  type        = "list"
}

variable "public_subnets" {
  description = "Subnet for Managed load balancers"
  type        = "list"
}

variable "private_subnets" {
  description = "Subnet for Admin load balancers"
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

variable "short_environment_name" {
  description = "Shortend name of the environment"
  type        = "string"
}

variable "bastion_inventory" {
  description = "Bastion environment inventory"
  type        = "string"
}

variable "project_name" {
  description = "The project name - eg. delius-core"
  type        = "string"
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
  type        = "string"
}

variable "vpc_account_id" {
  description = "VPC Account ID"
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

variable "certificate_arn" {
  description = "SSL certificate to be used for the external LB"
  type        = "string"
}

variable "weblogic_port" {
  description = "Port for the weblogic admin server"
  type        = "string"
}

variable "weblogic_tls_port" {
  description = "Secure port for the weblogic admin server"
  type        = "string"
}

variable "activemq_port" {
  description = "Port for the activemq server"
  type        = "string"
}

variable "activemq_enabled" {
  default     = "Whether the load balancer should listen to ActiveMQ connections"
  type        = "string"
}

variable "weblogic_health_check_path" {
  description = "parameters for the LB health check"
  type        = "string"
}

variable "app_bootstrap_name" {
  description = "app bootstrap name"
  type        = "string"
}

variable "app_bootstrap_src" {
  description = "app bootstrap src"
  type        = "string"
}

variable "app_bootstrap_version" {
  description = "app bootstrap version"
  type        = "string"
}

variable "app_bootstrap_initial_role" {
  description = "app bootstrap initial role name (may be same as app_bootstrap_name)"
  type        = "string"
}

variable "app_bootstrap_secondary_role" {
  description = "app bootstrap supplementary role name (optional)"
  type        = "string"
  default     = "nada"
}

variable "app_bootstrap_tertiary_role" {
  description = "app bootstrap tertiary role name (optional)"
  type        = "string"
  default     = "nada"
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = "map"
}
