# Listeners
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # NOTE:
  # This is only in place to support transition from the old public zone (dsd.io) to the strategic public zone (gov.uk).
  # It allows us to configure which zone to use for public-facing services (eg. NDelius, PWM) on a per-environment
  # basis. Currently only Prod and Pre-Prod should use the old public zone, once they are transitioned over we should
  # remove this. Additionally, there are a few services that have DNS records in the public zone that should be moved
  # over into the private zone before we complete the transition eg. delius-db-1, management.
  # (see dns.tf)
  certificate_arn = "${(var.delius_core_public_zone) == "strategic" ?
                      data.aws_acm_certificate.strategic_cert.arn :
                      data.aws_acm_certificate.cert.arn}"

  default_action {
    target_group_arn = "${module.service.target_group["arn"]}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  protocol          = "HTTP"
  port              = "80"

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
  name     = "${var.short_environment_name}-pwm-alb"
  internal = true

  security_groups = [
    "${data.terraform_remote_state.delius_core_security_groups.sg_pwm_lb_id}",
  ]

  subnets = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3
  )}"]

  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-pwm-alb"))}"

  lifecycle {
    create_before_destroy = true
  }
}
