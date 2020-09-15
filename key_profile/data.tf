#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the oracledb backup s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-oracledb-backups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "s3/oracledb-backups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the ldap backup s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-ldap-backups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "s3/ldap-backups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the test results s3 bucket
#-------------------------------------------------------------
data "terraform_remote_state" "s3-test-results" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "s3/test-results/terraform.tfstate"
    region = var.region
  }
}

