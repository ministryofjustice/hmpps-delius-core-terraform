# External ELB

module "external_lb" {
  source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_lb"
  lb_name         = "${var.short_environment_name}-${var.tier_name}-external"
  internal        = "false"
  security_groups = ["${var.external_elb_sg_id}"]
  subnet_ids      = ["${var.public_subnets}"]
  logs_enabled    = "false"
  s3_bucket_name  = ""
  tags            = "${var.tags}"
}

module "external_lb_target_group" {
  source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//targetgroup"
  appname             = "${var.short_environment_name}-${var.tier_name}"
  vpc_id              = "${var.vpc_id}"

  target_protocol     = "HTTP"
  target_port         = "${var.weblogic_port}"
  target_type         = "instance"

  check_protocol      = "HTTP"
  check_port          = "${var.weblogic_port}"
  check_path          = "${var.weblogic_health_check_path}"
  return_code         = "200"
  check_interval      = "30"
  timeout             = "15"
  healthy_threshold   = "2"
  unhealthy_threshold = "2"

  tags                = "${var.tags}"
}

module "external_lb_listener" {
  source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_listener_with_https"
  lb_arn              = "${module.external_lb.lb_arn}"
  lb_protocol         = "HTTPS"
  lb_port             = "443"
  target_group_arn    = "${module.external_lb_target_group.target_group_arn}"
  certificate_arn     = "${module.iam_server_certificate.arn}"
}

module "external_lb_listener_insecure" {
  source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//loadbalancer//alb//create_listener"
  lb_arn              = "${module.external_lb.lb_arn}"
  lb_protocol         = "HTTP"
  lb_port             = "80"
  target_group_arn    = "${module.external_lb_target_group.target_group_arn}"
}

resource "aws_app_cookie_stickiness_policy" "external_lb_jsessionid_stickiness_policy" {
  name          = "${var.short_environment_name}-${var.tier_name}-external-jsessionid"
  load_balancer = "${module.external_lb.lb_id}"
  lb_port       = 443
  cookie_name   = "JSESSIONID"
}

resource "aws_lb_listener_rule" "external_lb_redirect_http_to_https" {
  listener_arn = "${module.external_lb_listener_insecure.listener_arn}"
  action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  condition {
    field  = "host-header"
    values = ["*"]
  }
}

resource "aws_route53_record" "external_lb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.external_lb.lb_dns_name}"]
}

resource "aws_route53_record" "external_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.external_lb.lb_dns_name}"]
}

output "private_fqdn_external_lb" {
  value = "${aws_route53_record.external_lb_private.fqdn}"
}

output "public_fqdn_external_lb" {
  value = "${aws_route53_record.external_lb_public.fqdn}"
}
