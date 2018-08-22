resource "aws_security_group" "weblogic_oid_managed_elb" {
  name        = "${local.environment_name}-weblogic-oid-managed-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic oid admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_oid_elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow other weblogic domains into the managed boxes on the LDAP port

resource "aws_security_group_rule" "managed_elb_in_spg_managed" {
  from_port                = "${var.weblogic_domain_ports["oid_ldap"]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.weblogic_oid_managed_elb.id}"
  to_port                  = "${var.weblogic_domain_ports["oid_ldap"]}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed.id}"
}

resource "aws_security_group_rule" "managed_elb_in_interface_managed" {
  from_port                = "${var.weblogic_domain_ports["oid_ldap"]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.weblogic_oid_managed_elb.id}"
  to_port                  = "${var.weblogic_domain_ports["oid_ldap"]}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed.id}"
}

resource "aws_security_group_rule" "managed_elb_in_ndelius_managed" {
  from_port                = "${var.weblogic_domain_ports["oid_ldap"]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.weblogic_oid_managed_elb.id}"
  to_port                  = "${var.weblogic_domain_ports["oid_ldap"]}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
}

resource "aws_security_group" "weblogic_oid_admin_elb" {
  name        = "${local.environment_name}-weblogic-oid-admin-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic oid admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_oid_elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow admins into the admin box
resource "aws_security_group_rule" "admin_elb_in" {
  from_port         = "${var.weblogic_domain_ports["oid_admin"]}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.weblogic_oid_admin_elb.id}"
  to_port           = "${var.weblogic_domain_ports["oid_admin"]}"
  type              = "ingress"
  cidr_blocks       = "${var.bastion_cidrs}"
}

resource "aws_security_group" "weblogic_oid_admin" {
  name        = "${local.environment_name}-weblogic-oid-admin"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic oid admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_oid_admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "admin_elb" {
  from_port                = "${var.weblogic_domain_ports["oid_admin"]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.weblogic_oid_admin.id}"
  to_port                  = "${var.weblogic_domain_ports["oid_admin"]}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.weblogic_oid_admin_elb.id}"
}

resource "aws_security_group" "weblogic_oid_managed" {
  name        = "${local.environment_name}-weblogic-oid-managed"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic oid managed servers"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_oid_managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "oid_elb" {
  security_group_id        = "${aws_security_group.weblogic_oid_managed.id}"
  type                     = "ingress"
  from_port                = "${var.weblogic_domain_ports["oid_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["oid_managed"]}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed_elb.id}"
}
