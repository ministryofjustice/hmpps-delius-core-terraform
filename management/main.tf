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
data "aws_ami" "amazon_ami" {
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
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}



data "template_file" "user_data" {
  template = "${file("user_data/user_data.sh")}"

  vars {
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    environment_name              = "${data.terraform_remote_state.vpc.environment_name}"
    private_domain                = "${data.terraform_remote_state.vpc.private_zone_name}"
    account_id                    = "${data.terraform_remote_state.vpc.vpc_account_id}"
    bastion_inventory             = "${data.terraform_remote_state.vpc.bastion_inventory}"
    public_zone_id                = "${data.terraform_remote_state.vpc.public_zone_id}"
    private_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  }
}
