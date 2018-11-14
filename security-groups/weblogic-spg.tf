# weblogic-spg.tf

################################################################################
## weblogic-spg-managed-elb
################################################################################
resource "aws_security_group" "weblogic_spg_managed_elb" {
  name        = "${var.environment_name}-weblogic-spg-managed-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-managed-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_managed_elb_id" {
  value = "${aws_security_group.weblogic_spg_managed_elb.id}"
}

#Allow users into the managed boxes on the useful port
#TODO: Do we build a list of allowed source in or?
// resource "aws_security_group_rule" "spg_managed_elb_ingress" {
//   security_group_id = "${aws_security_group.weblogic_spg_managed_elb.id}"
//   type              = "ingress"
//   protocol          = "tcp"
//   from_port         = "${var.weblogic_domain_ports["spg_jms_broker"]}"
//   to_port           = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
//   cidr_blocks       = ["0.0.0.0/0"]
//   description       = "World in"
// }

################################################################################
## weblogic-spg-admin-elb
################################################################################
resource "aws_security_group" "weblogic_spg_admin_elb" {
  name        = "${var.environment_name}-weblogic-spg-admin-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-admin-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_admin_elb_id" {
  value = "${aws_security_group.weblogic_spg_admin_elb.id}"
}

#Allow admins into the admin box
resource "aws_security_group_rule" "spg_admin_elb_ingress" {
  security_group_id = "${aws_security_group.weblogic_spg_admin_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["spg_admin"]}"
  to_port           = "${var.weblogic_domain_ports["spg_admin"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

resource "aws_security_group_rule" "spg_admin_elb_ingress_delius_db" {
  security_group_id        = "${aws_security_group.weblogic_spg_admin_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["spg_jms_broker"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
  source_security_group_id = "${aws_security_group.delius_db_out.id}"
  description              = "From Delius db into SPG JMS Broker ELB"
}

################################################################################
## weblogic-spg-admin
################################################################################
resource "aws_security_group" "weblogic_spg_admin" {
  name        = "${var.environment_name}-weblogic-spg-admin"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_admin_id" {
  value = "${aws_security_group.weblogic_spg_admin.id}"
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "spg_admin_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_spg_admin.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["spg_admin"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_admin"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_admin_elb.id}"
  description              = "Admins via ELB in"
}

resource "aws_security_group_rule" "spg_admin_ingress_delius_db" {
  security_group_id        = "${aws_security_group.weblogic_spg_admin.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["spg_jms_broker"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
  source_security_group_id = "${aws_security_group.delius_db_out.id}"
  description              = "From Delius db into SPG JMS Broker"
}

resource "aws_security_group_rule" "spg_admin_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_spg_admin.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius db"
}

################################################################################
## weblogic-spg-managed
################################################################################
resource "aws_security_group" "weblogic_spg_managed" {
  name        = "${var.environment_name}-weblogic-spg-managed"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg managed servers"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_spg_managed_id" {
  value = "${aws_security_group.weblogic_spg_managed.id}"
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "spg_managed_ingress_elb" {
  security_group_id        = "${aws_security_group.weblogic_spg_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["spg_jms_broker"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed_elb.id}"
  description              = "ELB in"
}

resource "aws_security_group_rule" "spg_managed_egress_1521" {
  security_group_id        = "${aws_security_group.weblogic_spg_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius db"
}

resource "aws_security_group_rule" "spg_managed_egress_oid_ldap" {
  security_group_id        = "${aws_security_group.weblogic_spg_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "OID LDAP out"
}

resource "aws_security_group_rule" "spg_managed_egress_oid_ldap_elb" {
  security_group_id        = "${aws_security_group.weblogic_spg_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "OID LDAP ELB out"
}

## Allow access to SPG GW
resource "aws_security_group_rule" "spg_managed_egress_spg_gw" {
  security_group_id        = "${aws_security_group.weblogic_spg_managed.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["spg_jms_broker"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
  cidr_blocks              = ["${local.private_cidr_block}"]
  description              = "SPG GW out"
}
