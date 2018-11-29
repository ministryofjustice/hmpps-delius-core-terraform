# weblogic-oid.tf

################################################################################
## weblogic_oid_managed_elb
################################################################################
resource "aws_security_group" "weblogic_oid_managed_elb" {
  name        = "${var.environment_name}-weblogic-oid-managed-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic oid admin server"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-oid-managed-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_oid_managed_elb_id" {
  value = "${aws_security_group.weblogic_oid_managed_elb.id}"
}

#Allow other weblogic domains into the managed boxes on the LDAP port

resource "aws_security_group_rule" "managed_elb_ingress_interface_managed" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed.id}"
  description              = "Interface managed in"
}

resource "aws_security_group_rule" "managed_elb_ingress_ndelius_managed" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  description              = "Delius managed in"
}

resource "aws_security_group_rule" "managed_elb_ingress_spg_managed" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed.id}"
  description              = "SPG managed in"
}

################################################################################
## weblogic_oid_admin_elb
################################################################################
resource "aws_security_group" "weblogic_oid_admin_elb" {
  name        = "${var.environment_name}-weblogic-oid-admin-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic oid admin server"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-oid-admin-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_oid_admin_elb_id" {
  value = "${aws_security_group.weblogic_oid_admin_elb.id}"
}

#Allow admins into the admin box
resource "aws_security_group_rule" "oid_admin_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_oid_admin_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap"]}"
  to_port           = "${var.ldap_ports["ldap"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

#Allow admins into the admin box
resource "aws_security_group_rule" "oid_admin_tls_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_oid_admin_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap_tls"]}"
  to_port           = "${var.ldap_ports["ldap_tls"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

################################################################################
## weblogic_oid_admin
################################################################################
resource "aws_security_group" "weblogic_oid_admin" {
  name        = "${var.environment_name}-weblogic-oid-admin"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic oid admin server"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-oid-admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_oid_admin_id" {
  value = "${aws_security_group.weblogic_oid_admin.id}"
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "oid_admin_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_oid_admin.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_oid_admin_elb.id}"
}

resource "aws_security_group_rule" "oid_admin_ingress_bastion" {
  security_group_id = "${aws_security_group.weblogic_oid_admin.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap"]}"
  to_port           = "${var.ldap_ports["ldap"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

resource "aws_security_group_rule" "oid_admin_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_oid_admin.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.oid_db_in.id}"
  description              = "OID db"
}

################################################################################
## weblogic_oid_managed
################################################################################
resource "aws_security_group" "weblogic_oid_managed" {
  name        = "${var.environment_name}-weblogic-oid-managed"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic oid managed servers"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-oid-managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_oid_managed_id" {
  value = "${aws_security_group.weblogic_oid_managed.id}"
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "oid_managed_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed_elb.id}"
  description              = "ELB MANAGED IN"
}

resource "aws_security_group_rule" "oid_managed_ingress_ndelius_wls" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  description              = "NDELIUS IN"
}

resource "aws_security_group_rule" "oid_managed_ingress_spg_wls" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed.id}"
  description              = "SPG IN"
}

resource "aws_security_group_rule" "oid_managed_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.oid_db_in.id}"
  description              = "OID db"
}
