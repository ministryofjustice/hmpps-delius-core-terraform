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

#-------------------------------------------------------------
### Getting the shared vpc security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sub project keys and profiles
#-------------------------------------------------------------
data "terraform_remote_state" "key_profile" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/key_profile/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the database details
#-------------------------------------------------------------
data "terraform_remote_state" "database_failover" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/database_failover/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the EIPs
#-------------------------------------------------------------
data "terraform_remote_state" "persistent-eip" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "persistent-eip/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the LDAP
#-------------------------------------------------------------
data "terraform_remote_state" "ldap" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the Password Management Tool
#-------------------------------------------------------------
data "terraform_remote_state" "pwm" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/pwm/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the notification resources for Slack alerts
#-------------------------------------------------------------
data "terraform_remote_state" "alerts" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/alerts/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the bucket for storing access logs
#-------------------------------------------------------------
data "terraform_remote_state" "access_logs" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/access-logs/terraform.tfstate"
    region = var.region
  }
}

data "aws_ssm_parameter" "ami_version" {
  name = "/versions/delius-core/ami/weblogic/${var.environment_name}"
}

data "aws_ami" "centos_wls" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = [data.aws_ssm_parameter.ami_version.value]
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
  domain      = data.terraform_remote_state.vpc.outputs.public_ssl_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
}

data "aws_route53_zone" "private" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
}

