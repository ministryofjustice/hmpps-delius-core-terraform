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
### Getting the delius-core buckets
#-------------------------------------------------------------
data "terraform_remote_state" "s3buckets" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/s3buckets/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the EIPs
#-------------------------------------------------------------
data "terraform_remote_state" "persistent-eip" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "persistent-eip/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the user management tool
#-------------------------------------------------------------
data "terraform_remote_state" "umt" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/umt/terraform.tfstate"
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

#-------------------------------------------------------------
### Getting the Password Management Tool
#-------------------------------------------------------------
data "terraform_remote_state" "pwm" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/pwm/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_ami" "centos_wls" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    #values = ["HMPPS Delius-Core Weblogic-Admin master *"]
    values = ["HMPPS Delius-Core Weblogic-Admin master 1590148904"]
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

data "aws_acm_certificate" "cert" {
  domain      = "${data.terraform_remote_state.vpc.public_ssl_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "strategic_cert" {
  domain      = "*.${data.terraform_remote_state.vpc.strategic_public_zone_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
}

data "aws_route53_zone" "private" {
  zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
}
