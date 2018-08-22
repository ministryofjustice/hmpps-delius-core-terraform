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

data aws_subnet_ids "db" {
  tags = {
    Type = "db"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

#Allow bastion in on SSH
data "aws_security_group" "ssh_bastion_in" {
  name   = "${local.environment_name}-ssh-bastion-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

#Delius DB
data "aws_security_group" "delius_db_in" {
  name   = "${local.environment_name}-delius-db-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

#OID DB
data "aws_security_group" "oid_db_in" {
  name   = "${local.environment_name}-oid-db-in"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "oid_db_out" {
  name   = "${local.environment_name}-oid-db-out"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

#Interface security groups
data "aws_security_group" "weblogic_interface_managed_elb" {
  name   = "${local.environment_name}-weblogic-interface-managed-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_interface_admin_elb" {
  name   = "${local.environment_name}-weblogic-interface-admin-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_interface_admin" {
  name   = "${local.environment_name}-weblogic-interface-admin"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_interface_managed" {
  name   = "${local.environment_name}-weblogic-interface-managed"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

#ndelius security groups
data "aws_security_group" "weblogic_ndelius_managed_elb" {
  name   = "${local.environment_name}-weblogic-ndelius-managed-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_ndelius_admin_elb" {
  name   = "${local.environment_name}-weblogic-ndelius-admin-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_ndelius_admin" {
  name   = "${local.environment_name}-weblogic-ndelius-admin"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_ndelius_managed" {
  name   = "${local.environment_name}-weblogic-ndelius-managed"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

#oid security groups
data "aws_security_group" "weblogic_oid_managed_elb" {
  name   = "${local.environment_name}-weblogic-oid-managed-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_oid_admin_elb" {
  name   = "${local.environment_name}-weblogic-oid-admin-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_oid_admin" {
  name   = "${local.environment_name}-weblogic-oid-admin"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_oid_managed" {
  name   = "${local.environment_name}-weblogic-oid-managed"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

#spg security groups
data "aws_security_group" "weblogic_spg_managed_elb" {
  name   = "${local.environment_name}-weblogic-spg-managed-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_spg_admin_elb" {
  name   = "${local.environment_name}-weblogic-spg-admin-elb"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_spg_admin" {
  name   = "${local.environment_name}-weblogic-spg-admin"
  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_security_group" "weblogic_spg_managed" {
  name   = "${local.environment_name}-weblogic-spg-managed"
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

data "aws_route53_zone" "zone" {
  name         = "${var.environment_type}.${var.project_name}.${var.route53_domain_private}."
  private_zone = false
}
