variable "role_name" {
  description = "The IAM role name"
}

variable "environment_name" {
  description = "The environment name - e.g. delius-core-dev"
}

variable "dependencies_bucket_arn" {
  description = "The S3 bucket arn for software and application dependencies"
}

variable "s3_oracledb_backups_arn" {
  description = "The S3 bucket arn for oracle db data backups"
}

variable "s3_ldap_backups_arn" {
  description = "The S3 bucket arn for ldap ldif backups"
}

variable "s3_test_results_arn" {
  description = "The S3 bucket arn for performance test results"
}

variable "migration_bucket_arn" {
  description = "The S3 bucket arn for temporarily holding migrated data"
}
