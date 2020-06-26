resource "aws_lb_target_group" "target_group" {
  name        = "${var.short_environment_name}-${var.service_name}-tg"
  vpc_id      = "${var.vpc_id}"
  protocol    = "HTTP"
  port        = "${var.service_port}"
  target_type = "ip"                                                                                      # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.service_name}-tg"))}"

  health_check {
    protocol            = "HTTP"
    path                = "${var.health_check_path}"
    matcher             = "${var.health_check_matcher}"
    timeout             = "${var.health_check_timeout}"
    interval            = "${var.health_check_interval}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
  }

  stickiness {
    enabled = "${var.lb_stickiness_enabled}"
    type = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "forward_rule" {
  count        = "${var.lb_listener_arn != "" ? 1: 0}"
  listener_arn = "${var.lb_listener_arn}"

  condition {
    path_pattern {
      values = ["${var.lb_path_patterns}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
  }
}
