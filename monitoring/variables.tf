variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_name" {
  description = "Environment name to be used as a unique identifier for resources - eg. delius-core-dev"
}

variable "short_environment_name" {
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - eg. dlc-dev"
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

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = "string"
  default     = "nodejs12.x"
}
