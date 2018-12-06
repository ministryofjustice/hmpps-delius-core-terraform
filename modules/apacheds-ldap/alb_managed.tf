# # Managed ELB

resource "aws_lb" "managed" {
  name            = "${var.short_environment_name}-${var.tier_name}-managed"
  internal        = false
  ip_address_type = "ipv4"
  security_groups = ["${var.managed_elb_sg_id}"]
  subnets         = ["${var.public_subnets}"]
  tags            = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-managed"))}"
}

resource "aws_lb_target_group" "managed" {
  port     = "${var.managed_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  tags     = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-managed"))}"

  health_check {
    path = "${var.managed_health_check["path"]}"
    matcher = "${var.managed_health_check["matcher"]}"
  }
}

resource "aws_lb_target_group_attachment" "managed" {
  port             = "${var.managed_port}"
  target_group_arn = "${aws_lb_target_group.managed.arn}"
  target_id        = "${aws_instance.ldap.id}"
}

resource "aws_lb_listener" "managed" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.managed.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.managed.arn}"
  port              = "${var.managed_port}"
}

resource "aws_route53_record" "managed_lb_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-managed"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.managed.dns_name}"]
}

resource "aws_route53_record" "managed_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-managed"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.managed.dns_name}"]
}

output "internal_fqdn_managed_lb" {
  value = "${aws_route53_record.managed_lb_internal.fqdn}"
}

output "public_fqdn_managed_lb" {
  value = "${aws_route53_record.managed_lb_public.fqdn}"
}
