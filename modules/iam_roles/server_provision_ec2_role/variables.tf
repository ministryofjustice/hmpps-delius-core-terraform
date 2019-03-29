variable "role_name" {
  description = "The IAM role name"
}

variable "environment_name" {
  description = "The environment name - e.g. delius-core-dev"
}

variable "dependencies_bucket_arn" {
  description = "The S3 bucket arn for software and application dependencies"
}

variable "backups_bucket_arn" {
  description = "The S3 bucket arn for data backups"
}

variable "migration_bucket_arn" {
  description = "The S3 bucket arn for temporarily holding migrated data"
}
