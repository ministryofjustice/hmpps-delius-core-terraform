# weblogic-spg.tf

################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "weblogic_spg_lb" {
  name        = "${var.environment_name}-weblogic-spg-lb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg LB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-spg-lb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_lb_id" {
  value = "${aws_security_group.weblogic_spg_lb.id}"
}

resource "aws_security_group_rule" "spg_lb_ingress_nat" {
  security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.natgateway_public_ips_cidr_blocks}"]
  description       = "NAT gateway in"
}

resource "aws_security_group_rule" "spg_lb_ingress_nat_tls" {
  security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.natgateway_public_ips_cidr_blocks}"]
  description       = "NAT gateway in (TLS)"
}

resource "aws_security_group_rule" "spg_public_subnet_ingress" {
  security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.public_cidr_block}"]
  description       = "Public subnet in (required for NLB health-check)"
}

resource "aws_security_group_rule" "spg_lb_egress_wls" {
  security_group_id        = "${aws_security_group.weblogic_spg_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_instances.id}"
  description              = "Out to instances"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "weblogic_spg_instances" {
  name        = "${var.environment_name}-weblogic-spg-instances"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg instances"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-spg-instances", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_instances_id" {
  value = "${aws_security_group.weblogic_spg_instances.id}"
}

resource "aws_security_group_rule" "spg_instances_lb_ingress" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  description              = "Load balancer in"
}

resource "aws_security_group_rule" "spg_instances_ingress_activemq" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  to_port                  = "${var.weblogic_domain_ports["activemq_port"]}"
  source_security_group_id = "${aws_security_group.delius_db_out.id}"
  description              = "DB in to activemq"
}

resource "aws_security_group_rule" "spg_instances_egress_spg_gw" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.spg_partnergateway_domain_ports["jms_broker"]}"
  to_port                  = "${var.spg_partnergateway_domain_ports["jms_broker_ssl"]}"
  cidr_blocks              = ["${local.private_cidr_block}"]
  description              = "SPG GW out"
}

resource "aws_security_group_rule" "spg_instances_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "spg_instances_egress_ldap" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAP ELB out"
}
