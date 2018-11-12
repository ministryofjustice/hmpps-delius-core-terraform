# weblogic-ndelius.tf

################################################################################
## weblogic_ndelius_managed_elb
################################################################################
resource "aws_security_group" "weblogic_ndelius_managed_elb" {
  name        = "${var.environment_name}-weblogic-ndelius-managed-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic ndelius admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-ndelius-managed-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_managed_elb_id" {
  value = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
}

#Allow users into the managed boxes on the useful port
#TODO: Do we build a list of allowed source in or?
resource "aws_security_group_rule" "ndelius_managed_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["ndelius_managed"]}"
  to_port           = "${var.weblogic_domain_ports["ndelius_managed"]}"
  cidr_blocks       = ["${var.user_access_cidr_blocks}"]
  description       = "World in"
}

resource "aws_security_group_rule" "ndelius_managed_elb_egress_ndelius" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["ndelius_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["ndelius_managed"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  description              = "Out to ndelius service"
}

################################################################################
## weblogic_ndelius_admin_elb
################################################################################
resource "aws_security_group" "weblogic_ndelius_admin_elb" {
  name        = "${var.environment_name}-weblogic-ndelius-admin-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic ndelius admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-ndelius-admin-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_admin_elb_id" {
  value = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
}

#Allow admins into the admin box
resource "aws_security_group_rule" "ndelius_admin_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["ndelius_admin"]}"
  to_port           = "${var.weblogic_domain_ports["ndelius_admin"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

resource "aws_security_group_rule" "ndelius_admin_elb_egress_ndelius" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["ndelius_admin"]}"
  to_port                  = "${var.weblogic_domain_ports["ndelius_admin"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_admin.id}"
  description              = "Out to ndelius service"
}

################################################################################
## weblogic_ndelius_admin
################################################################################
resource "aws_security_group" "weblogic_ndelius_admin" {
  name        = "${var.environment_name}-weblogic-ndelius-admin"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic ndelius admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-ndelius-admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_admin_id" {
  value = "${aws_security_group.weblogic_ndelius_admin.id}"
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "ndelius_admin_elb_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_admin.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["ndelius_admin"]}"
  to_port                  = "${var.weblogic_domain_ports["ndelius_admin"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
  description              = "Admins via ELB in"
}

resource "aws_security_group_rule" "ndelius_admin_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_admin.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius db"
}

################################################################################
## weblogic_ndelius_managed
################################################################################
resource "aws_security_group" "weblogic_ndelius_managed" {
  name        = "${var.environment_name}-weblogic-ndelius-managed"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic ndelius managed servers"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-ndelius-managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_managed_id" {
  value = "${aws_security_group.weblogic_ndelius_managed.id}"
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "ndelius_managed_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["ndelius_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["ndelius_managed"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
  description              = "ELB in"
}

resource "aws_security_group_rule" "ndelius_managed_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius db"
}

resource "aws_security_group_rule" "ndelius_managed_egress_oid_ldap" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed.id}"
  description              = "OID LDAP out"
}

resource "aws_security_group_rule" "ndelius_managed_egress_oid_ldap_elb" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed_elb.id}"
  description              = "OID LDAP out"
}
