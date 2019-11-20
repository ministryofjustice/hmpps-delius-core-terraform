# weblogic-interface.tf

################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "weblogic_interface_lb" {
  name        = "${var.environment_name}-weblogic-interface-lb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic interface LB"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-interface-lb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_lb_id" {
  value = "${aws_security_group.weblogic_interface_lb.id}"
}

# Allow EIS users into the external ELB
#TODO: Do we build a list of allowed source in or?
#resource "aws_security_group_rule" "interface_external_elb_ingress" {
#  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
#  type              = "ingress"
#  protocol          = "tcp"
#  from_port         = "80"
#  to_port           = "80"
#  cidr_blocks       = ["0.0.0.0/0"]
#  description       = "Interface users in"
#}
#
#resource "aws_security_group_rule" "interface_external_elb_ingress_tls" {
#  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
#  type              = "ingress"
#  protocol          = "tcp"
#  from_port         = "443"
#  to_port           = "443"
#  cidr_blocks       = ["0.0.0.0/0"]
#  description       = "Interface users in (TLS)"
#}

resource "aws_security_group_rule" "interface_public_subnet_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.public_cidr_block}"]
  description       = "Public subnet in"
}

resource "aws_security_group_rule" "interface_public_subnet_ingress_tls" {
  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.public_cidr_block}"]
  description       = "Public subnet in (TLS)"
}

resource "aws_security_group_rule" "interface_external_elb_egress_wls" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  to_port                  = "${var.weblogic_domain_ports["weblogic_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_instances.id}"
  description              = "Out to instances"
}

resource "aws_security_group_rule" "interface_external_elb_egress_umt" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.umt_instances.id}"
  description              = "Out to UMT instances"
}

resource "aws_security_group_rule" "interface_lb_self_ingress" {
  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  self              = true
  description       = "LB-to-LB comms"
}

resource "aws_security_group_rule" "interface_lb_self_ingress_tls" {
  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  self              = true
  description       = "LB-to-LB comms (TLS)"
}

resource "aws_security_group_rule" "interface_lb_iaps_ingress_tls" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  source_security_group_id = "${local.iaps_sg_id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "IAPS Ingress (TLS)"
}


resource "aws_security_group_rule" "interface_lb_azure_communityproxy_ingress_tls" {
  count             = "${length(local.azure_community_proxy_source) >= 1 ? 1 : 0}"
  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  cidr_blocks       = ["${local.azure_community_proxy_source}"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  description       = "Azure Community Proxy Ingress (TLS)"
}

resource "aws_security_group_rule" "interface_lb_azure_oasys_ingress_tls" {
  count             = "${length(local.azure_oasys_proxy_source) >= 1 ? 1 : 0}"
  security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  cidr_blocks       = ["${local.azure_oasys_proxy_source}"]
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  description       = "Azure OASys Proxy Ingress (TLS)"
}



################################################################################
## Instances
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
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  description              = "Load balancer in"
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

resource "aws_security_group_rule" "interface_external_elb_egress_newtechweb" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "9000"
  to_port                  = "9000"
  source_security_group_id = "${aws_security_group.newtech_web.id}"
  description              = "Out to New Tech Web ECS Service"
}

resource "aws_security_group_rule" "interface_external_elb_ingress_casenotes" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  source_security_group_id = "${aws_security_group.newtech_casenotes_out.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "New Tech Casenotes Poll/Push Ingress to interface LB"
}

resource "aws_security_group_rule" "interface_external_elb_ingress_offenderapi" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  source_security_group_id = "${aws_security_group.newtech_offenderapi_out.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "New Tech Offender API Ingress to interface LB"
}

resource "aws_security_group_rule" "interface_external_elb_ingress_dss" {
  security_group_id        = "${aws_security_group.weblogic_interface_lb.id}"
  source_security_group_id = "${aws_security_group.delius_dss_out.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  description              = "Delius DSS Offloc Ingress to interface LB"
}
