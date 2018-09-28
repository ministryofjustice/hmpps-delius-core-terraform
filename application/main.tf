# terraform {
#   # The configuration for this backend will be filled in by Terragrunt
#   backend          "s3"             {}
#   required_version = "~> 0.11"
# }
#
# provider "aws" {
#   region  = "${var.region}"
#   version = "~> 1.16"
# }
#
# # Shared data and constants
#
# locals {
#   environment_name = "${var.project_name}-${var.environment_type}"
# }
#
# data "aws_vpc" "vpc" {
#   tags = {
#     Name = "${local.environment_name}"
#   }
# }
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
### Getting the shared vpc security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_ami" "centos" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos_wls" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Delius-Core Weblogic master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos_oracle_db" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    #values = ["HMPPS Delius-Core OracleDB master *"]
    #values = ["HMPPS Delius-Core OracleDB feature/oracleDB 1538137829"]
    values = ["HMPPS Delius-Core OracleDB feature/oracleDB 1538147935"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
