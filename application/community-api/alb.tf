locals {
  secured_endpoints  = ["/secure", "/secure/*"]
  metadata_endpoints = ["/health", "/health/*", "/ping", "/info"]
  documentation_endpoints = [
    "/swagger-*",
    "/webjars/springfox-swagger-ui/*",
    "/v2/api-docs", "/v3/api-docs",
  ]
}

# Load balancers
resource "aws_lb" "alb" {
  name            = "${var.short_environment_name}-${local.short_name}-alb"
  internal        = false
  subnets         = local.subnets.public
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_community_api_lb_id]
  tags            = merge(var.tags, { Name = "${var.short_environment_name}-${local.short_name}-alb" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "public_alb" {
  name     = "${var.short_environment_name}-${local.short_name}-pub-alb"
  internal = false
  subnets  = local.subnets.public
  security_groups = [ # Only attach the public security group if "enable_public_lb" is set to true
    local.app_config["enable_public_lb"] ?
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_community_api_public_lb_id : # Open to the world
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_community_api_lb_id          # Restricted by IP
  ]
  tags = merge(var.tags, { Name = "${var.short_environment_name}-${local.short_name}-pub-alb" })

  lifecycle {
    create_before_destroy = true
  }
}

# Listeners
resource "aws_lb_listener" "alb_listener" {
  # Default LB listener - forward traffic to public and secured endpoints only
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "403"
      content_type = "text/plain"
      message_body = "Access Denied. Only secured (/secure/*) endpoints are exposed via this URL."
    }
  }
}

resource "aws_lb_listener_rule" "alb_listener_secured_endpoints" {
  listener_arn = aws_lb_listener.alb_listener.arn
  condition {
    path_pattern { values = local.secured_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[0]["arn"]
  }
}

resource "aws_lb_listener_rule" "alb_listener_metadata_endpoints" {
  listener_arn = aws_lb_listener.alb_listener.arn
  condition {
    path_pattern { values = local.metadata_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[0]["arn"]
  }
}

resource "aws_lb_listener_rule" "alb_listener_documentation_endpoints" {
  listener_arn = aws_lb_listener.alb_listener.arn
  condition {
    path_pattern { values = local.documentation_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[0]["arn"]
  }
}

resource "aws_lb_listener" "public_alb_listener" {
  # Public LB listener - forward traffic for publicly available endpoints only (i.e. metadata + documentation)
  # Redirect any non-matching traffic to the swagger user interface
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.certificate_arn
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_302"
      path        = "/swagger-ui/index.html"
    }
  }
}

resource "aws_lb_listener_rule" "public_alb_metadata_endpoints" {
  listener_arn = aws_lb_listener.public_alb_listener.arn
  condition {
    path_pattern { values = local.metadata_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[1]["arn"]
  }
}

resource "aws_lb_listener_rule" "public_alb_documentation_endpoints" {
  listener_arn = aws_lb_listener.public_alb_listener.arn
  condition {
    path_pattern { values = local.documentation_endpoints }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.target_groups[1]["arn"]
  }
}

resource "aws_lb_listener" "http_listener" {
  # Redirect HTTP to HTTPS
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

resource "aws_lb_listener" "public_http_listener" {
  # Redirect HTTP to HTTPS
  load_balancer_arn = aws_lb.public_alb.arn
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
resource "aws_route53_record" "alb" {
  zone_id = local.route53_zone_id
  name    = local.app_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.alb.dns_name]
}

// TODO disabled for testing, the old record needs to be destroyed (from hmpps-delius-new-tech-terraform)
//resource "aws_route53_record" "secure_alb" {
//  # This record is enabled for backward-compatibility only.
//  # Clients should instead use the `community-api.*` URL (without the `-secure` suffix)
//  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
//  name    = "${local.app_name}-secure"
//  type    = "CNAME"
//  ttl     = 300
//  records = [aws_lb.alb.dns_name]
//}

resource "aws_route53_record" "public_alb" {
  zone_id = local.route53_zone_id
  name    = "${local.app_name}-public"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.public_alb.dns_name]
}

