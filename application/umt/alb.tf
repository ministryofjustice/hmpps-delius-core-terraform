# Target group
resource "aws_lb_target_group" "target_group" {
  name      = "${var.short_environment_name}-${local.app_name}"
  vpc_id    = "${data.terraform_remote_state.vpc.vpc_id}"
  protocol  = "HTTP"
  port      = "8080"
  tags      = "${merge(var.tags, map("Name", "${var.short_environment_name}-${local.app_name}"))}"
  health_check {
    protocol  = "HTTP"
    path      = "/umt/actuator/health"
    matcher   = "200-399"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_lb_target_group.target_group.arn}"
}

# Listeners
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${data.aws_acm_certificate.cert.arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn   = "${aws_lb.alb.arn}"
  protocol            = "HTTP"
  port                = "80"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Load balancer
resource "aws_lb" "alb" {
  name            = "${var.short_environment_name}-${local.app_name}-alb"
  internal        = true
  security_groups = [
    "${data.terraform_remote_state.delius_core_security_groups.sg_umt_lb_id}"
  ]
  subnets         = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3
  )}"]
  tags            = "${merge(var.tags, map("Name", "${var.short_environment_name}-${local.app_name}-alb"))}"
  lifecycle {
    create_before_destroy = true
  }
}
