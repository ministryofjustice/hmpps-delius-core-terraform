# Admin ELB

resource "aws_lb" "internal_lb" {
  name               = "${var.short_environment_name}-${var.tier_name}-internal"
  load_balancer_type = "network"
  internal           = true
  ip_address_type    = "ipv4"
  subnets            = ["${var.private_subnets}"]
  tags               = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-internal"))}"
}

resource "aws_lb_target_group" "ldap_instances_group" {
  port        = "${var.ldap_port}"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-internal"))}"
  stickiness  = []

  health_check {
    protocol  = "TCP"
    matcher   = ""
  }
}

resource "aws_lb_target_group_attachment" "internal_lb_group_attachment" {
  port             = "${var.ldap_port}"
  target_group_arn = "${aws_lb_target_group.ldap_instances_group.arn}"
  target_id        = "${aws_instance.ldap.id}"
}

resource "aws_lb_listener" "internal_lb_listener" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.ldap_instances_group.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.internal_lb.arn}"
  protocol          = "TCP"
  port              = "${var.ldap_port}"
}

resource "aws_route53_record" "internal_lb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.internal_lb.dns_name}"]
}

resource "aws_route53_record" "internal_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.internal_lb.dns_name}"]
}

output "private_fqdn_internal_lb" {
  value = "${aws_route53_record.internal_lb_private.fqdn}"
}

output "public_fqdn_internal_lb" {
  value = "${aws_route53_record.internal_lb_public.fqdn}"
}
