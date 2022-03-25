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
variable "s3_oracledb_backups_inventory_arn" {
  description = "The S3 bucket arn for oracle db data backups inventory file"
}
variable "s3_ldap_backups_arn" {
  description = "The S3 bucket arn for ldap ldif backups"
}

variable "s3_test_results_arn" {
  description = "The S3 bucket arn for performance test results"
}

variable "s3_ssm_ansible_arn" {
  description = "The S3 bucket arn for temporary Ansible files"
}

variable "migration_bucket_arn" {
  description = "The S3 bucket arn for temporarily holding migrated data"
}
variable "aws_account_ids" {
  type = map(string)
}
variable "aws_engineering_account_ids" {
  type = map(string)
}
