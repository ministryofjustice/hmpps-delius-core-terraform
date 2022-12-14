variable "environment_name" {
  type = string
}

variable "short_environment_name" {
  type = string
}

variable "project_name" {
  description = "The project name - delius-core"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
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

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "eng_remote_state_bucket_name" {
  description = "Engineering remote state bucket name"
}

variable "eng_role_arn" {
  description = "arn to use for engineering platform terraform"
}

variable "tags" {
  type = map(string)
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}
