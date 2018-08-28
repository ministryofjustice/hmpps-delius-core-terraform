resource "aws_security_group" "weblogic_interface_managed_elb" {
  name        = "${local.environment_name}-weblogic-interface-managed-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic interface admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_interface_elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow users into the managed boxes on the useful port
#TODO: Do we build a list of allowed source in or?
resource "aws_security_group_rule" "wime_managed_elb_in" {
  security_group_id = "${aws_security_group.weblogic_interface_managed_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["interface_managed"]}"
  to_port           = "${var.weblogic_domain_ports["interface_managed"]}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "weblogic_interface_admin_elb" {
  name        = "${local.environment_name}-weblogic-interface-admin-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic interface admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_interface_elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow admins into the admin box
resource "aws_security_group_rule" "wiae_admin_elb_in" {
  security_group_id = "${aws_security_group.weblogic_interface_admin_elb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "${var.weblogic_domain_ports["interface_admin"]}"
  to_port           = "${var.weblogic_domain_ports["interface_admin"]}"
  cidr_blocks       = "${var.bastion_cidrs}"
}

resource "aws_security_group" "weblogic_interface_admin" {
  name        = "${local.environment_name}-weblogic-interface-admin"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic interface admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_interface_admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "wia_admin_elb" {
  security_group_id        = "${aws_security_group.weblogic_interface_admin.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["interface_admin"]}"
  to_port                  = "${var.weblogic_domain_ports["interface_admin"]}"
  source_security_group_id = "${aws_security_group.weblogic_interface_admin_elb.id}"
}

resource "aws_security_group" "weblogic_interface_managed" {
  name        = "${local.environment_name}-weblogic-interface-managed"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic interface managed servers"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_interface_managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "interface_elb" {
  security_group_id        = "${aws_security_group.weblogic_interface_managed.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["interface_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["interface_managed"]}"  
  source_security_group_id = "${aws_security_group.weblogic_interface_managed_elb.id}"
}
