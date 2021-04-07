# *Legacy Load Balancer*
# Allows services to continue using the legacy url (community-api-secure.<env>.delius.probation.hmpps.dsd.io),
# while they migrate to using the new one (community-api.<env>.probation.service.justice.gov.uk).
# Once the old URL is no longer in use, this file can be deleted. The Load Balancer and DNS entries will then be automatically removed.

# Load balancers
resource "aws_lb" "legacy_alb" {
  name     = "${var.short_environment_name}-${local.short_name}-legacy"
  internal = false
  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3
  ]
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_community_api_lb_id]
  tags            = merge(var.tags, { Name = "${var.short_environment_name}-${local.short_name}-legacy" })

  access_logs {
    enabled = true
    bucket  = data.terraform_remote_state.access_logs.outputs.bucket_name
    prefix  = local.app_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Listeners
resource "aws_lb_listener" "legacy_alb_listener" {
  # Default LB listener - forward traffic to public and secured endpoints only
  load_balancer_arn = aws_lb.legacy_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.legacy_cert.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
    }
  }
}

resource "aws_lb_listener_rule" "legacy_alb_listener_secured_endpoints" {
  listener_arn = aws_lb_listener.legacy_alb_listener.arn
  condition {
    path_pattern { values = local.secured_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[2]["arn"]
  }
}

resource "aws_lb_listener_rule" "legacy_alb_listener_metadata_endpoints" {
  listener_arn = aws_lb_listener.legacy_alb_listener.arn
  condition {
    path_pattern { values = local.metadata_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[2]["arn"]
  }
}

resource "aws_lb_listener_rule" "legacy_alb_listener_documentation_endpoints" {
  listener_arn = aws_lb_listener.legacy_alb_listener.arn
  condition {
    path_pattern { values = local.documentation_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[2]["arn"]
  }
}

resource "aws_lb_listener" "legacy_http_listener" {
  # Redirect HTTP to HTTPS
  load_balancer_arn = aws_lb.legacy_alb.arn
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

# community-api-secure.<env>.delius.probation.hmpps.dsd.io
resource "aws_route53_record" "legacy_secure_url" {
  # This record is enabled for backward-compatibility only.
  # Clients should instead use the `community-api.*` URL (without the `-secure` suffix)
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "${local.app_name}-secure"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.legacy_alb.dns_name]
}