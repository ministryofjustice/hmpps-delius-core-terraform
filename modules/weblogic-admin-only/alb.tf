# Load balancer
resource "aws_lb" "alb" {
  name            = substr("${var.short_environment_name}-${var.app_name}-alb", 0, 32)
  internal        = false
  security_groups = var.security_groups_lb

  idle_timeout = var.idle_timeout

  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
  ]
  tags = merge(var.tags, { "Name" = substr("${var.short_environment_name}-${var.app_name}-alb", 0, 32) })

  access_logs {
    enabled = true
    bucket  = data.terraform_remote_state.access_logs.outputs.bucket_name
    prefix  = var.app_name
  }

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
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
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

# Listener rules
resource "aws_lb_listener_rule" "homepage_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  condition {
    path_pattern {
      values = ["/"]
    }
  }
  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
      path        = "/NDelius-war/delius/JSP/homepage.jsp"
    }
  }
  depends_on = [aws_lb_listener_rule.blocked_paths_listener_rule]
}

resource "aws_lb_listener_rule" "allowed_paths_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  condition {
    path_pattern {
      values = [
        "/NDelius*",
        "/jspellhtml/*",
        "/api/*"
      ]
    }
  }
  action {
    type             = "forward"
    target_group_arn = module.ecs.primary_target_group["arn"]
  }
  depends_on = [aws_lb_listener_rule.blocked_paths_listener_rule]
}

resource "aws_lb_listener_rule" "blocked_paths_listener_rule" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 1 # must be before ndelius_allowed_paths_rule
  condition {
    path_pattern {
      values = [
        "/NDelius*/delius/a4j/g/3_3_3.Final*DATA*", # mitigates CVE-2018-12533
      ]
    }
  }
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}
