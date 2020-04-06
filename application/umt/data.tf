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

data "terraform_remote_state" "key_profile" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/key_profile/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "s3buckets" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/s3buckets/terraform.tfstate"
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

data "terraform_remote_state" "interface" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/interface/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "spg" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/spg/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "pwm" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/pwm/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_route53_zone" "public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
}

data "aws_route53_zone" "private" {
  zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
}

data "aws_acm_certificate" "cert" {
  domain      = "${data.terraform_remote_state.vpc.public_ssl_domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_caller_identity" "current" {}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "template_file" "ecs_assume_role_policy_template" {
  template = "${file("${path.module}/templates/iam/ecs_assume_role_policy.json.tpl")}"
  vars {}
}

data "template_file" "ecs_exec_policy_template" {
  template = "${file("${path.module}/templates/iam/ecs_exec_policy.json.tpl")}"
  vars {
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    region           = "${var.region}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"
  }
}

data "template_file" "cw_logs_policy_template" {
  template = "${file("${path.module}/templates/iam/cloudwatch_logs_policy.json.tpl")}"
  vars {
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    region           = "${var.region}"
  }
}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"
  vars {
    region           = "${var.region}"
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    project_name     = "${var.project_name}"

    container_name  = "${local.app_name}"
    image_url       = "${local.image_url}"
    image_version   = "${local.umt_config["version"]}"
    log_group_name  = "${var.environment_name}/${local.app_name}"
    memory          = "${local.umt_config["memory"]}"
    cpu             = "${local.umt_config["cpu"]}"

    log_group_name        = "${var.environment_name}/${local.app_name}"
    database_url          = "${data.terraform_remote_state.database.jdbc_failover_url}"
    database_username     = "delius_app_schema"
    ldap_url              = "${data.terraform_remote_state.ldap.ldap_protocol}://${data.terraform_remote_state.ldap.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.ldap_port}"
    ldap_username         = "${local.ldap_config["bind_user"]}"
    ldap_base             = "${local.ldap_config["base_root"]}"
    ldap_base_users       = "${replace(local.ldap_config["base_users"], format(",%s", local.ldap_config["base_root"]), "")}"
    ldap_base_clients     = "${replace(local.ldap_config["base_service_users"], format(",%s", local.ldap_config["base_root"]), "")}"
    ldap_base_roles       = "${replace(local.ldap_config["base_roles"], format(",%s", local.ldap_config["base_root"]), "")}"
    ldap_base_role_groups = "${replace(local.ldap_config["base_role_groups"], format(",%s", local.ldap_config["base_root"]), "")}"
    ldap_base_groups      = "${replace(local.ldap_config["base_groups"], format(",%s", local.ldap_config["base_root"]), "")}"
    redis_host            = "${aws_route53_record.token_store_private_dns.fqdn}"
    redis_port            = "${aws_elasticache_replication_group.token_store_replication_group.port}"
    password_reset_url    = "https://${data.terraform_remote_state.pwm.public_fqdn_pwm}/public/forgottenpassword"
    ndelius_log_level     = "${local.ansible_vars["ndelius_log_level"]}"
  }
}
