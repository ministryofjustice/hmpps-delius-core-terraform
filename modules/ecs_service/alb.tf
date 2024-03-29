locals {
  lb_listener_arns   = length(var.lb_listener_arns) > 0 ? var.lb_listener_arns : (var.lb_listener_arn != "" ? [var.lb_listener_arn] : [])
  target_group_count = var.target_group_count + length(local.lb_listener_arns)
}

resource "aws_lb_target_group" "target_group" {
  count    = local.target_group_count
  name     = "${local.short_name}-tg${local.target_group_count == 1 ? "" : count.index + 1}"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  protocol = "HTTP"
  port     = var.service_port

  # Targets will be ECS tasks running in awsvpc mode so target_type needs to be ip
  target_type                   = "ip"
  deregistration_delay          = var.deregistration_delay
  load_balancing_algorithm_type = var.lb_algorithm_type

  tags = merge(var.tags, { "Name" = "${local.name}-tg${local.target_group_count == 1 ? "" : count.index + 1}" })

  health_check {
    protocol            = "HTTP"
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  stickiness {
    enabled = var.lb_stickiness_enabled
    type    = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "forward_rule" {
  count        = length(local.lb_listener_arns)
  listener_arn = local.lb_listener_arns[count.index]

  condition {
    path_pattern {
      values = var.lb_path_patterns
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
  }
}

