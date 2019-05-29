# External NLB to forward to internal ALB
resource "aws_lb" "external_nlb" {
  name               = "${var.short_environment_name}-${var.tier_name}-ext"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${var.public_subnets}"]
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-ext"))}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "external_nlb_target_group" {
  name      = "${var.short_environment_name}-${var.tier_name}-ext"
  vpc_id    = "${var.vpc_id}"
  target_type = "ip"
  protocol  = "TCP"
  port      = "443"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-ext"))}"
  health_check {
    protocol  = "TCP"
    port      = "443"
  }
}

module "lb-linker" "nlb-to-alb" {
  source  = "pbar1/lb-linker/aws"
  version = "1.0.0"
  name = "${var.short_environment_name}-${var.tier_name}-nlb-to-alb"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-nlb-to-alb"))}"
  nlb_tg_arn = "${aws_lb_target_group.external_nlb_target_group.arn}"
  alb_dns_name = "${aws_lb.internal_alb.dns_name}"
  s3_bucket = "${var.alb_ips_bucket}"
}

resource "aws_lb_listener" "external_nlb_listener" {
  load_balancer_arn = "${aws_lb.external_nlb.arn}"
  port              = "443"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.external_nlb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_route53_record" "external_nlb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.external_nlb.dns_name}"]
}

resource "aws_route53_record" "external_nlb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.external_nlb.dns_name}"]
}

output "private_fqdn_external_nlb" {
  value = "${aws_route53_record.external_nlb_private.fqdn}"
}

output "public_fqdn_external_nlb" {
  value = "${aws_route53_record.external_nlb_public.fqdn}"
}
