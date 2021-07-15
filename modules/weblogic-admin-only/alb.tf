# Load balancer
resource "aws_lb" "alb" {
  name            = "${var.short_environment_name}-${var.app_name}-alb"
  internal        = false
  security_groups = var.security_groups_lb
  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
  ]
  tags = merge(var.tags, { "Name" = "${var.short_environment_name}-${var.app_name}-alb" })

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
resource "aws_lb_listener_rule" "homepage_redirect_rule" {
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
}


resource "aws_lb_listener_rule" "ndelius_allowed_paths_rule" {
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
}
