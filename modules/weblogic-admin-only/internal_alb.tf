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
  name_prefix = "${local.tg_name_prefix}"
  vpc_id      = "${var.vpc_id}"
  protocol    = "HTTP"
  port        = "${var.weblogic_port}"
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-tg"))}"
  health_check {
    protocol            = "HTTP"
    port                = "${var.weblogic_port}"
    path                = "/${var.weblogic_health_check_path}"
    matcher             = "200"
    interval            = 60
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  stickiness {
    type = "lb_cookie"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "newtechweb_target_group" {
  name        = "${var.short_environment_name}-${var.tier_name}-ntw"
  vpc_id      = "${var.vpc_id}"
  protocol    = "HTTP"
  port        = "9000"
  target_type = "ip" # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-ntw"))}"
  health_check {
    protocol  = "HTTP"
    path      = "/newTech/healthcheck"
    matcher   = "200-399"
  }
}

resource "aws_lb_target_group" "gdpr_api_target_group" {
  name        = "${var.short_environment_name}-${local.tier_name_sub}-gdpr-api"
  vpc_id      = "${var.vpc_id}"
  protocol    = "HTTP"
  port        = "8080"
  target_type = "ip" # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-gdpr-api"))}"
  health_check {
    protocol  = "HTTP"
    path      = "/gdpr/api/actuator/health"
    matcher   = "200-399"
  }
}

resource "aws_lb_target_group" "gdpr_ui_target_group" {
  name        = "${var.short_environment_name}-${local.tier_name_sub}-gdpr-ui"
  vpc_id      = "${var.vpc_id}"
  protocol    = "HTTP"
  port        = "80"
  target_type = "ip" # Targets will be ECS tasks running in awsvpc mode so type needs to be ip
  tags        = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-gdpr-ui"))}"
  health_check {
    protocol  = "HTTP"
    path      = "/gdpr/ui/homepage"
    matcher   = "200-399"
  }
}

# Listeners
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

resource "aws_lb_listener" "internal_lb_https_listener" {
  load_balancer_arn = "${aws_lb.internal_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.certificate_arn}"
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
    }
  }
}

# Listener rules
resource "aws_lb_listener_rule" "internal_lb_ndelius_redirect_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/"]
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

resource "aws_lb_listener_rule" "internal_lb_ndelius_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/NDelius-war/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_root_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/NDelius-war"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_jspell_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/jspellhtml/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_newtechweb_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/newTech/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.newtechweb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_gdpr_api_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/gdpr/api/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.gdpr_api_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_gdpr_ui_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/gdpr/ui/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.gdpr_ui_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_iaps_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/NDeliusIAPS/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_dss_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/NDeliusDSS/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_casenotes_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/NDeliusAPI/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_oasys_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/NDeliusOASYS/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
  }
}

resource "aws_lb_listener_rule" "internal_lb_ndelius_api_rule" {
  listener_arn = "${aws_lb_listener.internal_lb_https_listener.arn}"
  condition {
    field  = "path-pattern"
    values = ["/api/*"]
  }
  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.internal_alb_target_group.arn}"
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
