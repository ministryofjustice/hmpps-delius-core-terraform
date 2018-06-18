variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius-core"
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

variable "route53_domain_private" {
  description = "The DNS domain for all HMPPS probation services"
}

variable "instance_type_weblogic" {
  description = "The ec2 instance type"
}

variable "instance_type_db" {
  description =  "The ec2 instance type"
}
