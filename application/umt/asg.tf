locals {
  # Override default values
  ansible_vars = "${merge(var.default_ansible_vars, var.ansible_vars)}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"
  vars {
    ecs_cluster_name    = "${aws_ecs_cluster.cluster.name}"
    bastion_inventory   = "${data.terraform_remote_state.vpc.bastion_inventory}"
    log_group_name      = "${var.environment_name}/${local.app_name}"
    region              = "${var.region}"
    environment_name    = "${var.environment_name}"
    project_name        = "${var.project_name}"
    config_location     = "${local.host_config_location}"
    database_url        = "${data.terraform_remote_state.database.jdbc_failover_url}"
    database_username   = "delius_app_schema"
    ldap_url            = "${data.terraform_remote_state.ldap.ldap_protocol}://${data.terraform_remote_state.ldap.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.ldap_port}"
    ldap_bind_username  = "${data.terraform_remote_state.ldap.ldap_bind_user}"
    ldap_user_base      = "${data.terraform_remote_state.ldap.ldap_base_users}"
    ndelius_log_level   = "${local.ansible_vars["ndelius_log_level"]}"
  }
}

resource "aws_launch_configuration" "launch_cfg" {
  name_prefix          = "${var.short_environment_name}-${local.app_name}-launch-cfg-"
  image_id             = "${data.aws_ami.ecs_ami.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  instance_type        = "${var.umt_config["instance_type"]}"
  security_groups      = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.vpc_security_groups.sg_smtp_ses}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_umt_instances_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
  ]
  enable_monitoring    = "true"
  user_data            = "${data.template_file.user_data.rendered}"
  root_block_device {
    volume_type        = "gp2"
    volume_size        = 50
  }
  lifecycle {
    create_before_destroy = true
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

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.environment_name}-${local.app_name}"
  vpc_zone_identifier       = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3
  )}"]
  launch_configuration      = "${aws_launch_configuration.launch_cfg.id}"
  min_size                  = "${var.umt_config["ec2_scaling_min_capacity"]}"
  max_size                  = "${var.umt_config["ec2_scaling_max_capacity"]}"
  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${var.environment_name}-${local.app_name}"
      propagate_at_launch = true
    }
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "up_policy" {
  name                   = "${var.environment_name}-${local.app_name}-scale-up-policy"
  scaling_adjustment     = "1"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_policy" "down_policy" {
  name                   = "${var.environment_name}-${local.app_name}-scale-down-policy"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "up_alarm" {
  alarm_name          = "${var.environment_name}-${local.app_name}-scale-up-alarm"
  alarm_description   = "ECS cluster scaling metric above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.umt_config["scale_up_cpu_threshold"]}"
  alarm_actions       = ["${aws_autoscaling_policy.up_policy.arn}"]
  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "down_alarm" {
  alarm_name          = "${var.environment_name}-${local.app_name}-scale-down-alarm"
  alarm_description   = "ECS cluster scaling metric under threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "15"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.umt_config["scale_down_cpu_threshold"]}"
  alarm_actions       = ["${aws_autoscaling_policy.down_policy.arn}"]
  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }
}
