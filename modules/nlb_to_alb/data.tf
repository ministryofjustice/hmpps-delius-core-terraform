data "template_file" "haproxy_cfg" {
  template = file("${path.module}/templates/haproxy.cfg.tpl")
  vars = {
    alb_fqdn       = var.alb_fqdn
    aws_nameserver = var.aws_nameserver
  }
}

data "template_file" "haproxy_user_data" {
  template = file("${path.module}/user_data/user_data.haproxy.sh")

  vars = {
    project_name         = var.project_name
    env_identifier       = var.environment_identifier
    short_env_identifier = var.short_environment_identifier
    region               = var.region
    app_name             = "${var.tier_name}-haproxy"
    route53_sub_domain   = var.environment_name
    environment_name     = var.environment_name
    private_domain       = var.private_domain
    account_id           = var.vpc_account_id
    bastion_inventory    = var.bastion_inventory
    haproxy_cfg          = data.template_file.haproxy_cfg.rendered
  }
}

data "aws_ssm_parameter" "ami_version" {
  name = "/versions/delius-core/ami/haproxy/${var.environment_name}"
}

data "aws_ami" "centos" {
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
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

