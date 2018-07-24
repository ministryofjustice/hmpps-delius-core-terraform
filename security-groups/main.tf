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

data "aws_subnet" "public_a" {
  tags = {
    Name = "${local.environment_name}_public_a"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}

data "aws_subnet" "public_b" {
  tags = {
    Name = "${local.environment_name}_public_b"
  }

  vpc_id = "${data.aws_vpc.vpc.id}"
}