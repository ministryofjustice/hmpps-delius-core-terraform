variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "short_environment_name" {
  type = "string"
}

variable "dependencies_bucket_arn" {
  description = "The S3 bucket arn for software and application dependencies"
}
