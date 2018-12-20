# weblogic-interface.tf

################################################################################
## weblogic_interface_external_elb
################################################################################
resource "aws_security_group" "weblogic_interface_external_elb" {
  name        = "${var.environment_name}-weblogic-interface-external-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface external ELB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-interface-external-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_external_elb_id" {
  value = "${aws_security_group.weblogic_interface_external_elb.id}"
}

# Allow EIS users into the external ELB
#TODO: Do we build a list of allowed source in or?
resource "aws_security_group_rule" "interface_external_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_external_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Interface users in"
}

resource "aws_security_group_rule" "spg_external_elb_egress_wls" {
  security_group_id        = "${aws_security_group.weblogic_interface_external_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_instances.id}"
  description              = "Out to wls instances"
}

################################################################################
## weblogic_interface_internal_elb
################################################################################
resource "aws_security_group" "weblogic_interface_internal_elb" {
  name        = "${var.environment_name}-weblogic-interface-internal-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface internal ELB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-interface-internal-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_internal_elb_id" {
  value = "${aws_security_group.weblogic_interface_internal_elb.id}"
}

#Allow admins into the internal ELB
resource "aws_security_group_rule" "interface_internal_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_internal_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port           = "${var.weblogic_domain_ports["weblogic_port"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

resource "aws_security_group_rule" "interface_internal_elb_egress_wls" {
  security_group_id        = "${aws_security_group.weblogic_interface_internal_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_instances.id}"
  description              = "ELB out"
}

################################################################################
## weblogic_interface_internal
################################################################################
resource "aws_security_group" "weblogic_interface_instances" {
  name        = "${var.environment_name}-weblogic-interface-instances"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface instances"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-interface-instances", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_instances_id" {
  value = "${aws_security_group.weblogic_interface_instances.id}"
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "interface_instances_external_elb_ingress" {
  security_group_id        = "${aws_security_group.weblogic_interface_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_external_elb.id}"
  description              = "External ELB in"
}

resource "aws_security_group_rule" "interface_instances_internal_elb_ingress" {
  security_group_id        = "${aws_security_group.weblogic_interface_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_internal_elb.id}"
  description              = "Internal ELB in"
}

resource "aws_security_group_rule" "interface_instances_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_interface_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "interface_instances_egress_ldap" {
  security_group_id        = "${aws_security_group.weblogic_interface_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAP ELB out"
}