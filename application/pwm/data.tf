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

data "aws_ssm_parameter" "config_password" {
  name            = "/${var.environment_name}/${var.project_name}/pwm/pwm/config_password"
  with_decryption = true
}

data "template_file" "task_policy_template" {
  template = "${file("templates/iam/task_policy.json.tpl")}"

  vars {
    bucket = "${aws_s3_bucket.config_bucket.arn}"
  }
}

data "template_file" "startup_script" {
  template = "${file("templates/pwm/startup.sh.tpl")}"

  vars {
    bucket      = "${local.bucket_name}"
    config_file = "${aws_s3_bucket_object.pwm_config_object.key}"
    war_file    = "${aws_s3_bucket_object.pwm_war_object.key}"
  }
}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"

  vars {
    region               = "${var.region}"
    app_name             = "${local.app_name}"
    tomcat_version       = "9" # using the latest 9.x version, to ensure we stay up-to-date with patches etc
    log_group_name       = "${var.environment_name}/${local.app_name}"
    ssm_prefix           = "${local.ssm_prefix}"
    config_password_hash = "${bcrypt(data.aws_ssm_parameter.config_password.value)}"
    cpu                  = "${local.pwm_config["cpu"]}"
    memory               = "${local.pwm_config["memory"]}"
    script               = "${base64encode(data.template_file.startup_script.rendered)}"
  }
}

data "template_file" "pwm_configuration" {
  template = "${file("templates/pwm/PwmConfiguration.xml.tpl")}"

  vars {
    # Here the config_password is hashed using bcrypt with a random 22-character salt. We then swap the first three
    # characters from $2b to $2a which ensures we don't get a salt revision error when PWM attempts to verify it.
    # {{ config_password | password_hash('blowfish', lookup('password', '/dev/null chars=ascii_letters,digits length=22')) | regex_replace('^\$2b', '$2a') }}
//    config_password_hash = "${bcrypt(data.aws_ssm_parameter.config_password)}"
    region             = "${var.region}"
    ldap_protocol      = "${data.terraform_remote_state.ldap.ldap_protocol}"
    ldap_host          = "${data.terraform_remote_state.ldap.private_fqdn_ldap_elb}"
    ldap_port          = "${data.terraform_remote_state.ldap.ldap_port}"
    ldap_bind_user     = "${data.terraform_remote_state.ldap.ldap_bind_user}"
    user_base          = "${data.terraform_remote_state.ldap.ldap_base_users}"
    site_url           = "https://${aws_route53_record.public_dns.fqdn}"
    email_smtp_address = "smtp.${data.terraform_remote_state.vpc.private_zone_name}"
    email_from_address = "no-reply@${data.terraform_remote_state.vpc.public_zone_name}"
  }
}