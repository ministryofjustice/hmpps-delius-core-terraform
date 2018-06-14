# Shared data and constants

locals {
  az_a = "eu-west-2a"
  az_b = "eu-west-2b"
  az_c = "eu-west-2c"
}

# The VPC, subnets etc

module "network" {
  source  = "modules/vpc_with_public_and_db_subnets"
  vpc_cidr = "${var.vpc_cidr}"
  tags = "${var.tags}"
  environment_name = "${local.environment_name}"
  az_a = "${local.az_a}"
  az_b = "${local.az_b}"
}
