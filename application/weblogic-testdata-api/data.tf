data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "alerts" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/alerts/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "natgateway" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "natgateway/terraform.tfstate"
    region = var.region
  }
}

####################################################
# Locals
####################################################

locals {
  natgateway_public_ips_cidr_blocks = [
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az1}/32",
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az2}/32",
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az3}/32",
  ]
}