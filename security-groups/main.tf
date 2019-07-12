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

data "terraform_remote_state" "natgateway" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "natgateway/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the shared oracle-db-operation security groups
#-------------------------------------------------------------
data "terraform_remote_state" "ora_db_op_security_groups" {
  backend = "s3"

  config {
    bucket   = "${var.eng_remote_state_bucket_name}"
    key      = "oracle-db-operation/security-groups/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.eng_role_arn}"
  }
}

#-------------------------------------------------------------
### Getting the engineering jenkins remote state
#-------------------------------------------------------------

data "terraform_remote_state" "service-jenkins-eng" {
  backend = "s3"

  config {
    bucket   = "${var.eng_remote_state_bucket_name}"
    key      = "service-jenkins-eng/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.eng_role_arn}"
  }
}

####################################################
# Locals
####################################################

locals {
  public_subnets = "${list(
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az3-cidr_block}",
  )}"

  private_subnets = "${list(
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3-cidr_block}",
  )}"

  db_subnets = "${list(
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az3-cidr_block}",
  )}"

  public_cidr_block = [
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_public-subnet-az3-cidr_block}",
  ]

  private_cidr_block = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3-cidr_block}",
  ]

  db_cidr_block = [
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az1-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az2-cidr_block}",
    "${data.terraform_remote_state.vpc.vpc_db-subnet-az3-cidr_block}",
  ]

  natgateway_public_ips_cidr_blocks = [
    "${data.terraform_remote_state.natgateway.natgateway_common-nat-public-ip-az1}/32",
    "${data.terraform_remote_state.natgateway.natgateway_common-nat-public-ip-az2}/32",
    "${data.terraform_remote_state.natgateway.natgateway_common-nat-public-ip-az3}/32",
  ]

  user_access_cidr_blocks = "${concat(
    "${var.user_access_cidr_blocks}",
    "${var.env_user_access_cidr_blocks}"
  )}"
}
