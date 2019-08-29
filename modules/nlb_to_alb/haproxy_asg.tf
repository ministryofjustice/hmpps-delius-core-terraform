# HAProxy auto-scaling group, used to filter traffic before it hits the internal ALB
resource "aws_launch_configuration" "haproxy_launch_cfg" {
  name_prefix                 = "${var.short_environment_name}-${var.tier_name}-haproxy-cfg-"
  image_id                    = "${data.aws_ami.centos.id}"
  instance_type               = "${var.haproxy_instance_type}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.haproxy_security_groups}"]
  associate_public_ip_address = "false"
  user_data                   = "${data.template_file.haproxy_user_data.rendered}"
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

resource "aws_autoscaling_attachment" "haproxy_asg_attachment_to_nlb_http" {
  autoscaling_group_name = "${aws_autoscaling_group.haproxy_asg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.external_nlb_http_target_group.arn}"
}

resource "aws_autoscaling_attachment" "haproxy_asg_attachment_to_nlb_https" {
  autoscaling_group_name = "${aws_autoscaling_group.haproxy_asg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.external_nlb_https_target_group.arn}"
}

resource "aws_autoscaling_group" "haproxy_asg" {
  name                 = "${var.short_environment_name}-${var.tier_name}-haproxy"
  vpc_zone_identifier  = ["${var.private_subnets}"]
  min_size             = "${var.haproxy_instance_count}"
  max_size             = "${var.haproxy_instance_count}"
  desired_capacity     = "${var.haproxy_instance_count}"
  launch_configuration = "${aws_launch_configuration.haproxy_launch_cfg.id}"
  enabled_metrics      = [
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
      value               = "${var.short_environment_name}-${var.tier_name}-haproxy-asg"
      propagate_at_launch = true
    }
  ]
}