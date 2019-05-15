terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the s3buckets
#-------------------------------------------------------------
data "terraform_remote_state" "s3bucket" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/s3buckets/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the oracledb backup s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-oracledb-backups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "s3/oracledb-backups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the oracledb backup s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-ldap-backups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "s3/ldap-backups/terraform.tfstate"
    region = "${var.region}"
  }
}
