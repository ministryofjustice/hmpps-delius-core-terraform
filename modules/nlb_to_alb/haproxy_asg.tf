# HAProxy auto-scaling group, used to filter traffic before it hits the internal ALB
resource "aws_launch_configuration" "haproxy_launch_cfg" {
  count                       = var.enabled ? 1 : 0
  name_prefix                 = "${var.short_environment_name}-${var.tier_name}-haproxy-cfg-"
  image_id                    = data.aws_ami.centos.id
  instance_type               = var.haproxy_instance_type
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  security_groups             = var.haproxy_security_groups
  associate_public_ip_address = "false"
  user_data                   = data.template_file.haproxy_user_data.rendered
  enable_monitoring           = "true"
  ebs_optimized               = "false"

  root_block_device {
    volume_type = "gp2"
    volume_size = 32
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "haproxy_asg_attachment_to_nlb_http" {
  count                  = var.enabled ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.haproxy_asg[0].id
  alb_target_group_arn   = aws_lb_target_group.external_nlb_http_target_group[0].arn
}

resource "aws_autoscaling_attachment" "haproxy_asg_attachment_to_nlb_https" {
  count                  = var.enabled ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.haproxy_asg[0].id
  alb_target_group_arn   = aws_lb_target_group.external_nlb_https_target_group[0].arn
}

resource "aws_autoscaling_group" "haproxy_asg" {
  count                = var.enabled ? 1 : 0
  name                 = "${var.short_environment_name}-${var.tier_name}-haproxy"
  vpc_zone_identifier  = var.private_subnets
  min_size             = var.haproxy_instance_count
  max_size             = var.haproxy_instance_count
  desired_capacity     = var.enabled ? var.haproxy_instance_count : 0
  launch_configuration = aws_launch_configuration.haproxy_launch_cfg[0].id
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  # Convert tag list to a map
  tags = [for key, value in merge(var.tags, { "Name" = "${var.short_environment_name}-${var.tier_name}-haproxy-asg" }) :
    {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  ]
}

