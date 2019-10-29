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

data "terraform_remote_state" "network_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the shared oracle-db-operation security groups
#-------------------------------------------------------------
data "terraform_remote_state" "ora_db_op_security_groups" {
  backend = "s3"

  config {
    bucket   = "${var.oracle_db_operation["eng_remote_state_bucket_name"]}"
    key      = "oracle-db-operation/security-groups/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.oracle_db_operation["eng_role_arn"]}"
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

#-------------------------------------------------------------
### Getting the bastion details
#-------------------------------------------------------------
data "terraform_remote_state" "bastion" {
  backend = "s3"

  config {
    bucket   = "${var.bastion_remote_state_bucket_name}"
    key      = "service-bastion/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.bastion_role_arn}"
  }
}

#-------------------------------------------------------------
### Getting the engineering jenkins windows slave remote state
#-------------------------------------------------------------
data "terraform_remote_state" "windows_slave" {
  backend = "s3"

  config {
    bucket   = "${var.eng_remote_state_bucket_name}"
    key      = "windows_slave/terraform.tfstate"
    region   = "${var.region}"
    role_arn = "${var.eng_role_arn}"
  }
}

#-------------------------------------------------------------
### IAPS Security Group State
#-------------------------------------------------------------
data "terraform_remote_state" "iaps-sg" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "iaps/security-groups/terraform.tfstate"
    region = "${var.region}"
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

  windows_slave_public_ip = [
    "${data.terraform_remote_state.windows_slave.windows_slave.public_ip}/32"
  ]

  bastion_public_ip = [
    "${data.terraform_remote_state.bastion.bastion_ip}/32"
  ]

  user_access_cidr_blocks = "${concat(
    "${var.user_access_cidr_blocks}",
    "${var.env_user_access_cidr_blocks}",
    "${local.windows_slave_public_ip}",
    "${local.bastion_public_ip}"
  )}"

  iaps_sg_id = "${data.terraform_remote_state.iaps-sg.security_groups_sg_internal_instance_id}"

  azure_community_proxy_source = "${var.azure_community_proxy_source}"
  azure_oasys_proxy_source = "${var.azure_oasys_proxy_source}"
}

output "user_access_cidr_blocks_concatenated" {
  value = "${local.user_access_cidr_blocks}"
}

output "windows_slave_public_ip" {
  value = "${local.windows_slave_public_ip}"
}

output "bastion_ip" {
  value = "${local.bastion_public_ip}"
}
