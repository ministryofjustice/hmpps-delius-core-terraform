# External ELB

resource "aws_elb" "external" {
  name            = "${var.short_environment_name}-${var.tier_name}-external"
  internal        = false
  security_groups = ["${var.external_elb_sg_id}"]
  subnets         = ["${var.public_subnets}"]
  tags            = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-external"))}"
  listener {
    instance_port = "${var.weblogic_port}"
    instance_protocol = "HTTP"
    lb_port = 80
    lb_protocol = "HTTP"
  }
  health_check {
    target = "HTTP:${var.weblogic_port}/${var.weblogic_health_check_path}"
    timeout = 15
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_route53_record" "external_lb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.external.dns_name}"]
}

resource "aws_route53_record" "external_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.external.dns_name}"]
}

output "private_fqdn_external_lb" {
  value = "${aws_route53_record.external_lb_private.fqdn}"
}

output "public_fqdn_external_lb" {
  value = "${aws_route53_record.external_lb_public.fqdn}"
}
