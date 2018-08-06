terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11"
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

# Shared data and constants

locals {
  environment_name = "${var.project_name}-${var.environment_type}"
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${local.environment_name}"
  }
}

data "aws_subnet_ids" "private" {
  tags = {
    Type = "private"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

data aws_subnet_ids "public" {
  tags = {
    Type = "public"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_subnet" "public_a" {
  tags = {
    Name = "${local.environment_name}_public_a"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_subnet" "db_a" {
  tags {
    Name = "${local.environment_name}_db_a"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_subnet" "private_a" {
  tags {
    Name = "${local.environment_name}_private_a"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "ssh_external_in" {
  name   = "${local.environment_name}-ssh-external-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_in" {
  name   = "${local.environment_name}-weblogic-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_out" {
  name   = "${local.environment_name}-weblogic-out"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "db_in" {
  name   = "${local.environment_name}-db-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "db_out" {
  name   = "${local.environment_name}-db-out"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_lb_in" {
  name = "${local.environment_name}-weblogic-lb-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_lb_out" {
  name = "${local.environment_name}-weblogic-lb-out"
  vpc_id = "${data.aws_vpc.vpc.id}"
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

data "aws_kms_key" "master" {
  key_id = "alias/${local.environment_name}-master"
}
