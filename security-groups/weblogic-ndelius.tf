# weblogic-ndelius.tf

################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "weblogic_ndelius_lb" {
  name        = "${var.environment_name}-weblogic-ndelius-lb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic ndelius LB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-ndelius-lb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_lb_id" {
  value = "${aws_security_group.weblogic_ndelius_lb.id}"
}

# Allow NPS+CRC users into the external ELB
#TODO: Do we build a list of allowed source in or?
resource "aws_security_group_rule" "ndelius_external_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.user_access_cidr_blocks}"]
  description       = "Front-end users in"
}

resource "aws_security_group_rule" "ndelius_external_elb_ingress_tls" {
  security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.user_access_cidr_blocks}"]
  description       = "Front-end users in (TLS)"
}

resource "aws_security_group_rule" "ndelius_external_elb_ingress_nat" {
  security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.natgateway_public_ips_cidr_blocks}"]
  description       = "NAT gateway in"
}

resource "aws_security_group_rule" "ndelius_external_elb_ingress_nat_tls" {
  security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.natgateway_public_ips_cidr_blocks}"]
  description       = "NAT gateway in (TLS)"
}

resource "aws_security_group_rule" "ndelius_external_elb_egress_wls" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_instances.id}"
  description              = "Out to instances"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "weblogic_ndelius_instances" {
  name        = "${var.environment_name}-weblogic-ndelius-instances"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic ndelius instances"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-ndelius-instances", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_instances_id" {
  value = "${aws_security_group.weblogic_ndelius_instances.id}"
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "ndelius_instances_external_elb_ingress" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  description              = "Load balancer in"
}

resource "aws_security_group_rule" "ndelius_instances_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "ndelius_instances_egress_ldap" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAP ELB out"
}
