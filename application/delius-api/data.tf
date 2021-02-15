data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "strategic_cert" {
  domain      = "*.${data.terraform_remote_state.vpc.outputs.strategic_public_zone_name}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "legacy_cert" {
  domain      = data.terraform_remote_state.vpc.outputs.public_ssl_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "ecs-cluster/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/database_failover/terraform.tfstate"
    region = var.region
  }
}

