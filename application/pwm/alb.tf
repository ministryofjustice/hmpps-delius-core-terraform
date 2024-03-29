# Listeners
resource "aws_lb_listener" "https_listener" {
  count = contains(local.migrated_envs, var.environment_name) ? 0 : 1
  load_balancer_arn = aws_lb.alb.arn
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
  certificate_arn = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = module.service.primary_target_group["arn"]
    type             = "forward"
  }
}

resource "aws_lb_listener" "https_listener_migrated" {
  count = contains(local.migrated_envs, var.environment_name) ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
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
  certificate_arn = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.cert.arn

  default_action {
    type = "redirect"
    redirect {
      host = "${local.migration_url[var.environment_name]}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
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
  name     = contains(local.migrated_envs, var.environment_name) ? "${var.short_environment_name}-pwm-alb-redir" : "${var.short_environment_name}-pwm-alb"
  internal = contains(local.migrated_envs, var.environment_name) ? false : true

  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_pwm_lb_id]

  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
  ]

  tags = merge(var.tags, { "Name" = "${var.short_environment_name}-pwm-alb" })

  lifecycle {
    create_before_destroy = true
  }
}

