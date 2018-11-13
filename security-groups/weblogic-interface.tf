# weblogic-interface.tf

################################################################################
## weblogic_interface_managed_elb
################################################################################
resource "aws_security_group" "weblogic_interface_managed_elb" {
  name        = "${var.environment_name}-weblogic-interface-managed-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-interface-managed-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_managed_elb_id" {
  value = "${aws_security_group.weblogic_interface_managed_elb.id}"
}

#Allow users into the managed boxes on the useful port
#TODO: Do we build a list of allowed source in or?
resource "aws_security_group_rule" "interface_managed_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_managed_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["interface_managed"]}"
  to_port           = "${var.weblogic_domain_ports["interface_managed"]}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "World in"
}

resource "aws_security_group_rule" "interface_managed_elb_egress" {
  security_group_id        = "${aws_security_group.weblogic_interface_managed_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["interface_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["interface_managed"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed.id}"
  description              = "ELB out"
}

################################################################################
## weblogic_interface_admin_elb
################################################################################
resource "aws_security_group" "weblogic_interface_admin_elb" {
  name        = "${var.environment_name}-weblogic-interface-admin-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-interface-admin-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_admin_elb_id" {
  value = "${aws_security_group.weblogic_interface_admin_elb.id}"
}

#Allow admins into the admin box
resource "aws_security_group_rule" "interface_admin_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_admin_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["interface_admin"]}"
  to_port           = "${var.weblogic_domain_ports["interface_admin"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

resource "aws_security_group_rule" "interface_admin_elb_egress" {
  security_group_id        = "${aws_security_group.weblogic_interface_admin_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["interface_admin"]}"
  to_port                  = "${var.weblogic_domain_ports["interface_admin"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_admin.id}"
  description              = "ELB out"
}

################################################################################
## weblogic_interface_admin
################################################################################
resource "aws_security_group" "weblogic_interface_admin" {
  name        = "${var.environment_name}-weblogic-interface-admin"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-interface-admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_admin_id" {
  value = "${aws_security_group.weblogic_interface_admin.id}"
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "interface_admin_elb_elb_ingress" {
  security_group_id        = "${aws_security_group.weblogic_interface_admin.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["interface_admin"]}"
  to_port                  = "${var.weblogic_domain_ports["interface_admin"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_admin_elb.id}"
  description              = "Admins via ELB in"
}

resource "aws_security_group_rule" "interface_admin_bastion_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_admin.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["interface_admin"]}"
  to_port           = "${var.weblogic_domain_ports["interface_admin"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in direct via bastion"
}

resource "aws_security_group_rule" "interface_admin_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_interface_admin.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius db out"
}

################################################################################
## weblogic_interface_managed
################################################################################
resource "aws_security_group" "weblogic_interface_managed" {
  name        = "${var.environment_name}-weblogic-interface-managed"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface managed servers"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-interface-managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_managed_id" {
  value = "${aws_security_group.weblogic_interface_managed.id}"
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "interface_managed_elb_elb_ingress" {
  security_group_id        = "${aws_security_group.weblogic_interface_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["interface_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["interface_managed"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed_elb.id}"
  description              = "ELB in"
}

resource "aws_security_group_rule" "interface_managed_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_interface_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius db out"
}

resource "aws_security_group_rule" "interface_managed_egress_oid_ldap" {
  security_group_id        = "${aws_security_group.weblogic_interface_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "OID LDAP out"
}

resource "aws_security_group_rule" "interface_managed_egress_oid_ldap_elb" {
  security_group_id        = "${aws_security_group.weblogic_interface_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "OID LDAP ELB out"
}
