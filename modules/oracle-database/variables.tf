variable "server_name" {
  description = "The name of the server, dns name"
  type        = "string"
}

variable "ami_id" {
  description = "AWS AMI ID"
  type        = "string"
}

variable "instance_type" {
  description = "Instance type for the admin server"
  type        = "string"
}

variable "db_subnet" {
  description = "Subnet for the servers"
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

variable "security_group_ids" {
  description = "Security groups for the admin server"
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

variable "vpc_account_id" {
  description = "VPC Account ID"
  type        = "string"
}
