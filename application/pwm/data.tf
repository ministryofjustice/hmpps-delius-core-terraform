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

data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "key_profile" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/key_profile/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "persistent-eip" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "persistent-eip/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ldap" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ldap/terraform.tfstate"
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

data "aws_acm_certificate" "cert" {
  domain = data.terraform_remote_state.vpc.outputs.public_ssl_domain

  types = [
    "AMAZON_ISSUED",
  ]
  statuses = ["ISSUED", "EXPIRED"]

  most_recent = true
}

data "aws_acm_certificate" "strategic_cert" {
  domain = "*.${data.terraform_remote_state.vpc.outputs.strategic_public_zone_name}"

  types = [
    "AMAZON_ISSUED",
  ]
  statuses = ["ISSUED", "EXPIRED"]

  most_recent = true
}


data "aws_ssm_parameter" "mp_ldap_password" {
  name = "/mp/ldap/root_pw"
}

data "aws_ssm_parameter" "mp_ldap_principal" {
  name = "/mp/ldap/principal"
}

data "aws_ssm_parameter" "mp_ldap_host" {
  name = "/mp/ldap/host"
}

data "aws_ssm_parameter" "mp_ldap_user_base" {
  name = "/mp/ldap/mp_ldap_user_base"
}
