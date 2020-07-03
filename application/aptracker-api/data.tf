data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
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

data "terraform_remote_state" "database" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/database_failover/terraform.tfstate"
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

data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_caller_identity" "current" {}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"
  vars {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"

    container_name  = "${local.app_name}"
    image_url       = "${local.image_url}"
    image_version   = "${local.aptracker_api_config["version"]}"
    log_group_name  = "${var.environment_name}/${local.app_name}"
    memory          = "${local.aptracker_api_config["memory"]}"
    cpu             = "${local.aptracker_api_config["cpu"]}"

    log_group_name    = "${var.environment_name}/${local.app_name}"
    log_level         = "${local.aptracker_api_config["log_level"]}"

    database_url      = "${data.terraform_remote_state.database.jdbc_failover_url}"
    database_username = "delius_app_schema"
    oauth_token_uri   = "https://${data.terraform_remote_state.ndelius.public_fqdn_ndelius_wls_external}/umt/oauth/check_token"
  }
}
