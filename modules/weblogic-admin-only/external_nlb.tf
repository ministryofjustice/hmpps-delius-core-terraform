# External NLB to forward to internal ALB
resource "aws_lb" "external_nlb" {
  name               = "${var.short_environment_name}-${var.tier_name}-ext"
  internal           = false
  load_balancer_type = "network"
  tags               = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-ext"))}"
  subnet_mapping {
    subnet_id     = "${var.public_subnets[0]}"
    allocation_id = "${var.eip_allocation_ids[0]}"
  }
  subnet_mapping {
    subnet_id     = "${var.public_subnets[1]}"
    allocation_id = "${var.eip_allocation_ids[1]}"
  }
  subnet_mapping {
    subnet_id     = "${var.public_subnets[2]}"
    allocation_id = "${var.eip_allocation_ids[2]}"
  }
}

resource "aws_lb_target_group" "external_nlb_https_target_group" {
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

resource "aws_lb_target_group" "external_nlb_http_target_group" {
  name      = "${var.short_environment_name}-${var.tier_name}-e80"
  vpc_id    = "${var.vpc_id}"
  target_type = "ip"
  protocol  = "TCP"
  port      = "80"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-e80"))}"
  health_check {
    protocol  = "TCP"
    port      = "80"
  }
}

module "nlb_to_alb_https" {
  source  = "pbar1/lb-linker/aws"
  version = "1.0.0"
  name = "${var.short_environment_name}-${var.tier_name}-nlb-to-alb-https"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-nlb-to-alb-https"))}"
  nlb_tg_arn = "${aws_lb_target_group.external_nlb_https_target_group.arn}"
  alb_dns_name = "${aws_lb.internal_alb.dns_name}"
  alb_listener = "443"
  s3_bucket = "${var.alb_ips_bucket}"
}

module "nlb_to_alb_http" {
  source  = "pbar1/lb-linker/aws"
  version = "1.0.0"
  name = "${var.short_environment_name}-${var.tier_name}-nlb-to-alb-http"
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-nlb-to-alb-http"))}"
  nlb_tg_arn = "${aws_lb_target_group.external_nlb_http_target_group.arn}"
  alb_dns_name = "${aws_lb.internal_alb.dns_name}"
  alb_listener = "80"
  s3_bucket = "${var.alb_ips_bucket}"
}

resource "aws_lb_listener" "external_nlb_https_listener" {
  load_balancer_arn = "${aws_lb.external_nlb.arn}"
  port              = "443"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.external_nlb_https_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "external_nlb_http_listener" {
  load_balancer_arn = "${aws_lb.external_nlb.arn}"
  port              = "80"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.external_nlb_http_target_group.arn}"
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
