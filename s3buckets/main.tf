terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

####################################################
# Locals
####################################################

locals {
  common_name = "${var.environment_identifier}-backups"
  tags        = "${var.tags}"
}

############################################
# S3 Buckets
############################################

# #-------------------------------------------
# ### S3 bucket for backups
# #--------------------------------------------

module "s3bucket" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//s3bucket//s3bucket_without_policy"
  s3_bucket_name = "${local.common_name}"
  tags           = "${local.tags}"
  versioning     = false
}

# #-------------------------------------------
# ### S3 bucket for storing ALB IPs
# #--------------------------------------------

module "alb-ips-bucket" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//s3bucket//s3bucket_without_policy"
  s3_bucket_name = "${var.environment_identifier}-alb-ips"
  tags           = "${local.tags}"
  versioning     = false
}
