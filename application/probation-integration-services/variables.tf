variable "remote_state_bucket_name" {}
variable "region" {}
variable "project_name" {}
variable "environment_name" {}
variable "short_environment_name" {}
variable "bastion_remote_state_bucket_name" {}
variable "bastion_role_arn" {}
variable "delius_core_public_zone" { default = "strategic" }
variable "moj_cloud_platform_cidr_blocks" {}
variable "internal_moj_access_cidr_blocks" {}
variable "tags" { type = map(string) }
