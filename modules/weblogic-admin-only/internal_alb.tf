# Internal ALB for application
resource "aws_lb" "internal_alb" {
  name            = "${var.short_environment_name}-${var.tier_name}-alb"
  internal        = true
  security_groups = ["${var.lb_security_groups}"]
  subnets         = ["${var.private_subnets}"]
  tags            = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-alb"))}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "internal_alb_target_group" {
  name      = "${var.short_environment_name}-${var.tier_name}-alb"
  vpc_id    = "${var.vpc_id}"
  protocol  = "HTTP"
  port      = "${var.weblogic_port}"
  tags      = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-alb"))}"
  health_check {
    protocol  = "HTTP"
    port      = "${var.weblogic_port}"
    path      = "/${var.weblogic_health_check_path}"
    matcher   = "200"
  }
  stickiness {
    type = "lb_cookie"
  }
}

# Listeners
resource "aws_lb_listener" "internal_lb_https_listener" {
  load_balancer_arn = "${aws_lb.internal_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.certificate_arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "internal_lb_http_listener" {
  load_balancer_arn   = "${aws_lb.internal_alb.arn}"
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

resource "aws_lb_listener_rule" "internal_lb_console_redirect" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/console/*"]
  }
  action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "/"
    }
  }
}

# DNS
resource "aws_route53_record" "internal_alb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-app-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.internal_alb.dns_name}"]
}

resource "aws_route53_record" "internal_alb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-app-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.internal_alb.dns_name}"]
}

output "private_fqdn_internal_alb" {
  value = "${aws_route53_record.internal_alb_private.fqdn}"
}

output "public_fqdn_internal_alb" {
  value = "${aws_route53_record.internal_alb_public.fqdn}"
}
