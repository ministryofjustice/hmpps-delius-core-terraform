terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

variable "region" {}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}
