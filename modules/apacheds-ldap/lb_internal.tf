# Admin ELB
resource "aws_elb" "ldap_internal_lb" {
  name                  = "${var.short_environment_name}-${var.tier_name}-elb"
  internal              = true
  subnets               = ["${var.private_subnets}"]
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-internal"))}"
  instances             = ["${aws_instance.ldap.id}"]
  listener {
    instance_port       = "${var.ldap_port}"
    instance_protocol   = "tcp"
    lb_port             = "${var.ldap_port}"
    lb_protocol         = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:10389"
    interval            = 30
  }
}

resource "aws_route53_record" "internal_lb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-elb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ldap_internal_lb.dns_name}"]
}

resource "aws_route53_record" "internal_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-elb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ldap_internal_lb.dns_name}"]
}

output "private_fqdn_internal_lb" {
  value = "${aws_route53_record.internal_lb_private.fqdn}"
}

output "public_fqdn_internal_lb" {
  value = "${aws_route53_record.internal_lb_public.fqdn}"
}
