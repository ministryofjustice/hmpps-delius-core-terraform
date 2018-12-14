# apacheds-ldap.tf

################################################################################
## apacheds_ldap_private_elb
################################################################################
resource "aws_security_group" "apacheds_ldap_private_elb" {
  name        = "${var.environment_name}-apacheds-ldap-private-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Apache DS LDAP Server Private ELB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-apacheds-ldap-private-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_apacheds_ldap_private_elb_id" {
  value = "${aws_security_group.apacheds_ldap_private_elb.id}"
}

#Allow admins in via private elb
resource "aws_security_group_rule" "apacheds_ldap_private_elb_ingress_bastion" {
  security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap"]}"
  to_port           = "${var.ldap_ports["ldap"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

#Allow elb egress to apacheds_ldap sg
resource "aws_security_group_rule" "apacheds_ldap_private_elb_egress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "LB out to LDAP"
}

################################################################################
## apacheds_ldap
################################################################################
resource "aws_security_group" "apacheds_ldap" {
  name        = "${var.environment_name}-apacheds-ldap"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "ApacheDS LDAP server"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-apacheds-ldap", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_apacheds_ldap_id" {
  value = "${aws_security_group.apacheds_ldap.id}"
}

#Allow admins in via bastion
resource "aws_security_group_rule" "apacheds_ldap_tls_bastion_ingress" {
  security_group_id = "${aws_security_group.apacheds_ldap.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap_tls"]}"
  to_port           = "${var.ldap_ports["ldap_tls"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
}

#Allow the private ELB into LDAP server
resource "aws_security_group_rule" "apacheds_ldap_ingress_private_elb" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAP via LB"
}

#Allow the private ELB into LDAP server
resource "aws_security_group_rule" "apacheds_ldap_tls_ingress_private_elb" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap_tls"]}"
  to_port                  = "${var.ldap_ports["ldap_tls"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAPS via LB"
}

#Allow weblogic domains into the LDAP instances
resource "aws_security_group_rule" "apacheds_ldap_elb_weblogic_interface_ingress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_admin.id}"
  description              = "Interface in"
}

resource "aws_security_group_rule" "apacheds_ldap_elb_weblogic_ndelius_ingress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_admin.id}"
  description              = "Delius in"
}

resource "aws_security_group_rule" "apacheds_ldap_elb_weblogic_spg_ingress" {
  security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type = "ingress"
  protocol = "tcp"
  from_port = "${var.ldap_ports["ldap"]}"
  to_port = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_admin.id}"
  description = "SPG in"
}