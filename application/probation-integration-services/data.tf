data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "strategic_cert" {
  domain      = "*.${data.terraform_remote_state.vpc.outputs.strategic_public_zone_name}"
  types       = ["AMAZON_ISSUED"]
  statuses    = ["ISSUED", "EXPIRED"]
  most_recent = true
}

data "aws_acm_certificate" "legacy_cert" {
  domain      = data.terraform_remote_state.vpc.outputs.public_ssl_domain
  types       = ["AMAZON_ISSUED"]
  statuses    = ["ISSUED", "EXPIRED"]
  most_recent = true
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket   = var.bastion_remote_state_bucket_name
    key      = "service-bastion/terraform.tfstate"
    region   = var.region
    role_arn = var.bastion_role_arn
  }
}

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

data "terraform_remote_state" "access_logs" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/access-logs/terraform.tfstate"
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

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/database_failover/terraform.tfstate"
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
