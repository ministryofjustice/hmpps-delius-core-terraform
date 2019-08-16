# Internal ELB for JMS queues
resource "aws_elb" "jms_lb" {
  name            = "${var.short_environment_name}-jms-lb"
  internal        = true
  security_groups = ["${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_spg_lb_id}"]
  subnets         = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"]
  tags            = "${merge(var.tags, map("Name", "${var.environment_name}-jms-lb"))}"
  listener {
    instance_port     = "${var.weblogic_domain_ports["activemq_port"]}"
    instance_protocol = "TCP"
    lb_port           = "${var.weblogic_domain_ports["activemq_port"]}"
    lb_protocol       = "TCP"
  }
  health_check {
    target = "TCP:${var.weblogic_domain_ports["activemq_port"]}"
    timeout = 15
    interval = 30
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_attachment" "jms_asg_attachment" {
  autoscaling_group_name = "${module.spg.asg["name"]}"
  elb                    = "${aws_elb.jms_lb.id}"
}

# DNS
resource "aws_route53_record" "jms_private" {
  zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
  name    = "delius-jms"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.jms_lb.dns_name}"]
}

resource "aws_route53_record" "jms_public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  name    = "delius-jms"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.jms_lb.dns_name}"]
}

output "private_fqdn_jms_broker" {
  value = "${aws_route53_record.jms_private.fqdn}"
}

output "public_fqdn_jms_broker" {
  value = "${aws_route53_record.jms_public.fqdn}"
}
