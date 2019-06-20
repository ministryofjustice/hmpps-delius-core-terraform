terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

############################################
# S3 Buckets
############################################

# #-------------------------------------------
# ### S3 bucket for storing ALB IPs
# #--------------------------------------------

module "alb-ips-bucket" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//s3bucket//s3bucket_without_policy"
  s3_bucket_name = "${var.environment_identifier}-alb-ips"
  tags           = "${var.tags}"
  versioning     = false
}
