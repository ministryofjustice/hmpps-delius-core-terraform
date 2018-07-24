variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius core"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "vpc_cidr" {
  description = "The CIDR block assigned to the VPC"
}

variable "tags" {
  type        = "map"
  description = "Default tag set"
}

variable "bastion_account_id" {
  description = "Account ID the bastion lives in"
  type = "string"
}

variable "bastion_vpc_id" {
  description = "VPC ID of the bastion VPC"
  type = "string"
}

variable "bastion_cidrs" {
  description = "A list of the subnets the bastion can be in"
  type = "list"
}