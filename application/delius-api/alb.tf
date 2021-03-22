# Load balancer
resource "aws_lb" "alb" {
  name            = "${var.short_environment_name}-${local.app_name}-alb"
  internal        = false
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_api_lb_id]
  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
  ]
  tags = merge(var.tags, { "Name" = "${var.short_environment_name}-${local.app_name}-alb" })

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
  certificate_arn   = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.legacy_cert.arn

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
  zone_id = var.delius_core_public_zone == "strategic" ? data.terraform_remote_state.vpc.outputs.strategic_public_zone_id : data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = local.app_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}

