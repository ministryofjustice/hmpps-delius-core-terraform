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

variable "route53_domain_private" {
  description = "The DNS domain for all HMPPS probation services"
}

variable "dependencies_bucket_arn" {
  description = "The S3 bucket arn for software and application dependencies"
}
