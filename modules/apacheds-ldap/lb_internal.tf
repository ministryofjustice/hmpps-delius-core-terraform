# Master ELB (read-write)
resource "aws_elb" "ldap_master_lb" {
  name                  = "${var.short_environment_name}-${var.tier_name}-elb"
  internal              = true
  subnets               = ["${var.private_subnets}"]
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-master-lb"))}"
  security_groups       = ["${var.admin_elb_sg_id}"]
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

# Slave ELB (read-only)
resource "aws_elb" "ldap_readonly_lb" {
  name                  = "${var.short_environment_name}-${var.tier_name}-ro-elb"
  internal              = true
  subnets               = ["${var.private_subnets}"]
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-ro-lb"))}"
  security_groups       = ["${var.admin_elb_sg_id}"]
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

resource "aws_route53_record" "ldap_elb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-elb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ldap_master_lb.dns_name}"]
}

resource "aws_route53_record" "ldap_elb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-elb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ldap_master_lb.dns_name}"]
}

output "private_fqdn_ldap_elb" {
  value = "${aws_route53_record.ldap_elb_private.fqdn}"
}

output "public_fqdn_ldap_elb" {
  value = "${aws_route53_record.ldap_elb_public.fqdn}"
}

resource "aws_route53_record" "ldap_readonly_elb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-readonly-elb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ldap_master_lb.dns_name}"]
}

resource "aws_route53_record" "ldap_readonly_elb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-readonly-elb"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.ldap_master_lb.dns_name}"]
}

output "private_fqdn_readonly_ldap_elb" {
  value = "${aws_route53_record.ldap_readonly_elb_private.fqdn}"
}

output "public_fqdn_readonly_ldap_elb" {
  value = "${aws_route53_record.ldap_readonly_elb_public.fqdn}"
}
