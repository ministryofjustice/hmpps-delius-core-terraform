# apacheds-ldap.tf

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

#Allow other weblogic domains into the LDAP instances
resource "aws_security_group_rule" "weblogic_interface_to_ldap" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed.id}"
  description              = "Interface managed in"
}

resource "aws_security_group_rule" "weblogic_ndelius_to_ldap" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  description              = "Delius managed in"
}

resource "aws_security_group_rule" "weblogic_spg_to_ldap" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed.id}"
  description              = "SPG managed in"
}

#Allow admins in via bastion
resource "aws_security_group_rule" "apacheds_ldap_bastion_ingress" {
  security_group_id = "${aws_security_group.apacheds_ldap.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap"]}"
  to_port           = "${var.ldap_ports["ldap"]}"
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}"]
  description       = "Admins in via bastion"
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

#Temp allow anything in the private subnet access to LDAP server
resource "aws_security_group_rule" "apacheds_ldap_ingress_private_subnet" {
  security_group_id = "${aws_security_group.apacheds_ldap.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap"]}"
  to_port           = "${var.ldap_ports["ldap"]}"
  cidr_blocks       = ["${local.private_cidr_block}"]
  description       = "LDAP via LB"
}

#Temp allow anything in the private subnet access to LDAP server
resource "aws_security_group_rule" "apacheds_ldap_tls_ingress_private_subnet" {
  security_group_id = "${aws_security_group.apacheds_ldap.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap_tls"]}"
  to_port           = "${var.ldap_ports["ldap_tls"]}"
  cidr_blocks       = ["${local.private_cidr_block}"]
  description       = "LDAPS via LB"
}
