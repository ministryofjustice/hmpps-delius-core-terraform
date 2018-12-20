# weblogic-spg.tf

################################################################################
## weblogic_spg_internal_elb
################################################################################
resource "aws_security_group" "weblogic_spg_internal_elb" {
  name        = "${var.environment_name}-weblogic-spg-internal-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg internal ELB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-spg-internal-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_internal_elb_id" {
  value = "${aws_security_group.weblogic_spg_internal_elb.id}"
}

#Allow admins into the internal ELB
resource "aws_security_group_rule" "spg_internal_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_spg_internal_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port           = "${var.weblogic_domain_ports["weblogic_port"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

resource "aws_security_group_rule" "spg_internal_elb_egress_wls" {
  security_group_id        = "${aws_security_group.weblogic_spg_internal_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_instances.id}"
  description              = "Out to wls instances"
}

resource "aws_security_group_rule" "spg_internal_elb_egress_wls_activemq" {
  security_group_id        = "${aws_security_group.weblogic_spg_internal_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  to_port                  = "${var.weblogic_domain_ports["activemq_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_instances.id}"
  description              = "Out to wls activemq instances"
}

resource "aws_security_group_rule" "spg_internal_elb_ingress_delius_db" {
  security_group_id        = "${aws_security_group.weblogic_spg_internal_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  to_port                  = "${var.weblogic_domain_ports["activemq_port"]}"
  source_security_group_id = "${aws_security_group.delius_db_out.id}"
  description              = "In from database"
}

## Allow access from SPG GW
resource "aws_security_group_rule" "spg_internal_elb_ingress_spg_gw" {
  security_group_id        = "${aws_security_group.weblogic_spg_internal_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  to_port                  = "${var.weblogic_domain_ports["activemq_port"]}"
  cidr_blocks              = ["${local.private_cidr_block}"]
  description              = "SPG GW in"
}

## Allow access to SPG GW
resource "aws_security_group_rule" "spg_internal_elb_egress_spg_gw" {
  security_group_id        = "${aws_security_group.weblogic_spg_internal_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.spg_partnergateway_domain_ports["jms_broker"]}"
  to_port                  = "${var.spg_partnergateway_domain_ports["jms_broker_ssl"]}"
  cidr_blocks              = ["${local.private_cidr_block}"]
  description              = "SPG GW out"
}

################################################################################
## weblogic_spg_internal
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

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "spg_instances_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_internal_elb.id}"
  description              = "Internal ELB in"
}

resource "aws_security_group_rule" "spg_instances_activemq_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_spg_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  to_port                  = "${var.weblogic_domain_ports["activemq_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_internal_elb.id}"
  description              = "Internal ELB in to activemq"
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