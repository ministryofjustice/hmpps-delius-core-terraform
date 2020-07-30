terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.70.0"
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

#-------------------------------------------------------------
### Getting the sub project keys and profiles
#-------------------------------------------------------------
data "terraform_remote_state" "key_profile" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/key_profile/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the database details
#-------------------------------------------------------------
data "terraform_remote_state" "database_failover" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/database_failover/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the LDAP
#-------------------------------------------------------------
data "terraform_remote_state" "ldap" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_route53_zone" "public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
}

data "aws_route53_zone" "private" {
  zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
}

data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Delius-Core Oracle Client master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}


locals {
  ansible_vars = "${merge(var.default_ansible_vars, var.ansible_vars)}"
}

data "template_file" "user_data" {
  template = "${file("user_data/user_data.sh")}"

  vars {
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    project_name                  = "${var.project_name}"
    environment_name              = "${data.terraform_remote_state.vpc.environment_name}"
    private_domain                = "${data.terraform_remote_state.vpc.private_zone_name}"
    account_id                    = "${data.terraform_remote_state.vpc.vpc_account_id}"
    bastion_inventory             = "${data.terraform_remote_state.vpc.bastion_inventory}"
    public_zone_id                = "${data.terraform_remote_state.vpc.public_zone_id}"
    private_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
    database_host                 = "${data.terraform_remote_state.database_failover.public_fqdn_delius_db_1}"
    database_sid                  = "${local.ansible_vars["database_sid"]}"
    ldap_host                     = "${data.terraform_remote_state.ldap.private_fqdn_ldap_elb}"
    ldap_port                     = "${var.ldap_ports["ldap"]}"
  }
}
