data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "ecs-cluster/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "key_profile" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/key_profile/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "persistent-eip" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "persistent-eip/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "ldap" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_acm_certificate" "cert" {
  domain = "${data.terraform_remote_state.vpc.public_ssl_domain}"

  types = [
    "AMAZON_ISSUED",
  ]

  most_recent = true
}

data "aws_acm_certificate" "strategic_cert" {
  domain = "*.${data.terraform_remote_state.vpc.strategic_public_zone_name}"

  types = [
    "AMAZON_ISSUED",
  ]

  most_recent = true
}

data "aws_caller_identity" "current" {}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"

  vars {
    region          = "${var.region}"
    container_name  = "${local.app_name}"
    image_url       = "${local.image_url}"
    image_version   = "${local.image_version}"
    config_location = "${local.config_location}"
    log_group_name  = "${var.environment_name}/${local.app_name}"
    cpu             = "${local.pwm_config["cpu"]}"
    memory          = "${local.pwm_config["memory"]}"
  }
}
