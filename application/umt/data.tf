data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
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

data "terraform_remote_state" "ldap" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ldap/terraform.tfstate"
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

data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/weblogic-app/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "pwm" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/pwm/terraform.tfstate"
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

data "aws_route53_zone" "private" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
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
