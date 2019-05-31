# Internal NLB for JMS queues
resource "aws_lb" "internal_nlb" {
  name               = "${var.short_environment_name}-${var.tier_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${var.private_subnets}"]
  tags = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-nlb"))}"
}

resource "aws_lb_target_group" "internal_nlb_target_group" {
  name      = "${var.short_environment_name}-${var.tier_name}-nlb"
  vpc_id    = "${var.vpc_id}"
  protocol  = "TCP"
  port      = "${var.activemq_port}"
  tags      = "${merge(var.tags, map("Name", "${var.short_environment_name}-${var.tier_name}-nlb"))}"
  health_check {
    protocol  = "TCP"
    port      = "${var.activemq_port}"
  }
}

resource "aws_lb_listener" "internal_lb_activemq_listener" {
  load_balancer_arn = "${aws_lb.internal_nlb.arn}"
  port              = "${var.activemq_port}"
  protocol          = "TCP"
  default_action {
    target_group_arn = "${aws_lb_target_group.internal_nlb_target_group.arn}"
    type             = "forward"
  }
}

# DNS
resource "aws_route53_record" "internal_nlb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.internal_nlb.dns_name}"]
}

resource "aws_route53_record" "internal_nlb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.internal_nlb.dns_name}"]
}

output "private_fqdn_internal_nlb" {
  value = "${aws_route53_record.internal_nlb_private.fqdn}"
}

output "public_fqdn_internal_nlb" {
  value = "${aws_route53_record.internal_nlb_public.fqdn}"
}
