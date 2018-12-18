# Internal ELB

resource "aws_elb" "internal" {
  name            = "${var.short_environment_name}-${var.tier_name}-internal"
  internal        = true
  security_groups = ["${var.internal_elb_sg_id}"]
  subnets         = ["${var.private_subnets}"]
  tags            = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-internal"))}"
  instances       = ["${aws_instance.wls.id}"]
  listener {
    instance_port = "${var.weblogic_port}"
    instance_protocol = "HTTP"
    lb_port = "${var.weblogic_port}"
    lb_protocol = "HTTP"
  }
  listener {
    instance_port = "${var.weblogic_tls_port}"
    instance_protocol = "HTTPS"
    lb_port = "${var.weblogic_tls_port}"
    lb_protocol = "HTTPS"
  }
  listener {
    instance_port = "${var.activemq_port}"
    instance_protocol = "TCP"
    lb_port = "${var.activemq_port}"
    lb_protocol = "TCP"
    enabled = "${var.activemq_enabled}"
  }
  health_check {
    target = "HTTP:${var.weblogic_port}/${var.weblogic_health_check_path}"
    timeout = 15
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
    enabled = "${var.activemq_enabled == "true"? "false": "true"}"
  }
  health_check {
    target = "TCP:${var.activemq_port}"
    timeout = 15
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
    enabled = "${var.activemq_enabled}"
  }
}

resource "aws_route53_record" "internal_lb_private" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.internal.dns_name}"]
}

resource "aws_route53_record" "internal_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-internal"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.internal.dns_name}"]
}

output "private_fqdn_internal_lb" {
  value = "${aws_route53_record.internal_lb_private.fqdn}"
}

output "public_fqdn_internal_lb" {
  value = "${aws_route53_record.internal_lb_public.fqdn}"
}
