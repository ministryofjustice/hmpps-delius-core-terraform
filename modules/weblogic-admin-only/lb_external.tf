# External ELB
resource "aws_lb" "external_lb" {
  name               = "${var.short_environment_name}-${var.tier_name}-ext"
  internal           = "false"
  load_balancer_type = "application"
  security_groups    = ["${var.external_elb_sg_id}"]
  subnets            = ["${var.public_subnets}"]

  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-ext"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "external_lb_target_group" {
  name      = "${var.short_environment_name}-${var.tier_name}-tg"
  vpc_id    = "${var.vpc_id}"

  protocol  = "HTTP"
  port      = "${var.weblogic_port}"

  health_check {
    protocol  = "HTTP"
    port      = "${var.weblogic_port}"
    path      = "/${var.weblogic_health_check_path}"
    matcher   = "200"
  }
  stickiness {
    type = "lb_cookie"
  }

  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-tg"))}"
}

module "external_lb_listener" {
  source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_listener_with_https"
  lb_arn              = "${aws_lb.external_lb.arn}"
  lb_protocol         = "HTTPS"
  lb_port             = "443"
  target_group_arn    = "${aws_lb_target_group.external_lb_target_group.arn}"
  certificate_arn     = ["${var.certificate_arn}"]
}

resource "aws_lb_listener" "external_lb_listener_insecure" {
  load_balancer_arn   = "${aws_lb.external_lb.arn}"
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

resource "aws_lb_listener_rule" "external_lb_console_redirect" {
  listener_arn = "${module.external_lb_listener.listener_arn}"
  "condition" {
    field  = "path-pattern"
    values = ["/console/*"]
  }
  "action" {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      path        = "/"
    }
  }
}

resource "aws_route53_record" "external_lb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.external_lb.dns_name}"]
}

resource "aws_route53_record" "external_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.external_lb.dns_name}"]
}

output "private_fqdn_external_lb" {
  value = "${aws_route53_record.external_lb_private.fqdn}"
}

output "public_fqdn_external_lb" {
  value = "${aws_route53_record.external_lb_public.fqdn}"
}
