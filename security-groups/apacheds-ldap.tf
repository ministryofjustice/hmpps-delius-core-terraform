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

#Allow admins in via private elb
resource "aws_security_group_rule" "apacheds_ldap_tls_private_elb_ingress_bastion" {
  security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap_tls"]}"
  to_port           = "${var.ldap_ports["ldap_tls"]}"
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

#Allow elb egress to apacheds_ldap sg
resource "aws_security_group_rule" "apacheds_ldap_tls_private_elb_egress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap_tls"]}"
  to_port                  = "${var.ldap_ports["ldap_tls"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "LB out to LDAPS"
}

#Allow the slaves to see the master LB
resource "aws_security_group_rule" "apacheds_ldap_instances_egress_to_lb" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "Instances to LB"
}

resource "aws_security_group_rule" "apacheds_ldap_lb_ingress_from_instances" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "LB from instances"
}

#Allow the slaves to see the master LB (TLS)
resource "aws_security_group_rule" "apacheds_ldap_instances_egress_to_lb_tls" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap_tls"]}"
  to_port                  = "${var.ldap_ports["ldap_tls"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "Instances to LB TLS"
}

resource "aws_security_group_rule" "apacheds_ldap_lb_ingress_from_instances_tls" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap_tls"]}"
  to_port                  = "${var.ldap_ports["ldap_tls"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "LB from instances TLS"
}

#Allow weblogic domains into the LDAP instances
resource "aws_security_group_rule" "apacheds_ldap_elb_weblogic_interface_ingress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_instances.id}"
  description              = "Interface in"
}

resource "aws_security_group_rule" "apacheds_ldap_elb_weblogic_ndelius_ingress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_instances.id}"
  description              = "Delius in"
}

resource "aws_security_group_rule" "apacheds_ldap_elb_weblogic_spg_ingress" {
  security_group_id        = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_instances.id}"
  description              = "SPG in"
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

#Allow the master+slaves to see each other
resource "aws_security_group_rule" "apacheds_ldap_instances_ingress" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "Master/slave ingress"
}

#Allow the master+slaves to see each other
resource "aws_security_group_rule" "apacheds_ldap_instances_egress" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "Master/slave egress"
}

#Allow the master+slaves to see each other
resource "aws_security_group_rule" "apacheds_ldap_instances_ingress_tls" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap_tls"]}"
  to_port                  = "${var.ldap_ports["ldap_tls"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "Master/slave ingress TLS"
}

#Allow the master+slaves to see each other
resource "aws_security_group_rule" "apacheds_ldap_instances_egress_tls" {
  security_group_id        = "${aws_security_group.apacheds_ldap.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap_tls"]}"
  to_port                  = "${var.ldap_ports["ldap_tls"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap.id}"
  description              = "Master/slave egress TLS"
}