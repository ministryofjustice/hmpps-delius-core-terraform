# Load balancer
resource "aws_lb" "alb" {
  name            = "${var.short_environment_name}-${local.short_name}-alb"
  internal        = false
  security_groups = local.security_groups.load_balancer
  subnets         = local.subnets.public
  tags            = merge(var.tags, { "Name" = "${var.short_environment_name}-${local.short_name}-alb" })

  lifecycle {
    create_before_destroy = true
  }
}

# Listeners
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.govuk_cert.arn

  default_action {
    target_group_arn = module.ecs.primary_target_group["arn"]
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# DNS
resource "aws_route53_record" "public_dns" {
  zone_id = data.terraform_remote_state.vpc.outputs.strategic_public_zone_id
  name    = local.app_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}

