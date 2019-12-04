# WebLogic auto-scaling group with fixed instance count

resource "aws_launch_configuration" "wls_launch_cfg" {
  name_prefix                 = "${var.environment_name}-${var.tier_name}-launch-cfg-"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.instance_security_groups}"]
  associate_public_ip_address = "false"
  user_data                   = "${data.template_file.user_data.rendered}"
  enable_monitoring           = "true"
  ebs_optimized               = "false"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "wls_asg_attachment_to_alb" {
  autoscaling_group_name = "${aws_autoscaling_group.wls_asg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.internal_alb_target_group.arn}"
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

resource "aws_autoscaling_group" "wls_asg" {
  name                 = "${var.environment_name}-${var.tier_name}"
  vpc_zone_identifier  = ["${var.private_subnets}"]
  min_size             = "${var.instance_count}"
  max_size             = "${var.instance_count}"
  desired_capacity     = "${var.instance_count}"
  launch_configuration = "${aws_launch_configuration.wls_launch_cfg.id}"
  health_check_type    = "EC2"
  enabled_metrics           = [
    "GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances",
    "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"
  ]
  lifecycle {
    create_before_destroy = true
  }

  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${var.environment_name}-${var.tier_name}-asg"
      propagate_at_launch = true
    },
    {
      key                 = "ndelius_version"
      value               = "None deployed"
      propagate_at_launch = true
    }
  ]
}
