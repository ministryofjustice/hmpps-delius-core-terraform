data "template_file" "haproxy_cfg" {
  template = "${file("${path.module}/templates/haproxy.cfg.tpl")}"
  vars {
    alb_fqdn = "${var.alb_fqdn}"
  }
}

data "template_file" "haproxy_user_data" {
  template = "${file("${path.module}/user_data/user_data.haproxy.sh")}"

  vars {
    project_name         = "${var.project_name}"
    env_identifier       = "${var.environment_identifier}"
    short_env_identifier = "${var.short_environment_identifier}"
    region               = "${var.region}"
    app_name             = "${var.tier_name}-haproxy"
    route53_sub_domain   = "${var.environment_name}"
    environment_name     = "${var.environment_name}"
    private_domain       = "${var.private_domain}"
    account_id           = "${var.vpc_account_id}"
    bastion_inventory    = "${var.bastion_inventory}"
    haproxy_cfg          = "${data.template_file.haproxy_cfg.rendered}"
  }
}

data "aws_ami" "centos" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS master *"]
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
    name = "root-device-type"
    values = ["ebs"]
  }
}

# This null_data_source is required to convert our Map of tags, to the required List of tags for ASGs
# see: https://github.com/hashicorp/terraform/issues/16980
data "null_data_source" "tags" {
  count = "${length(keys(var.tags))}"
  inputs = {
    key                 = "${element(keys(var.tags), count.index)}"
    value               = "${element(values(var.tags), count.index)}"
    propagate_at_launch = true
  }
}