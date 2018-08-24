resource "aws_security_group" "weblogic_ndelius_managed_elb" {
  name        = "${local.environment_name}-weblogic-ndelius-managed-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic ndelius admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_ndelius_elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow users into the managed boxes on the useful port
#TODO: Do we build a list of allowed source in or?
resource "aws_security_group_rule" "wnme_managed_elb_in" {
  from_port         = "${var.weblogic_domain_ports["ndelius_managed"]}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
  to_port           = "${var.weblogic_domain_ports["ndelius_managed"]}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "weblogic_ndelius_admin_elb" {
  name        = "${local.environment_name}-weblogic-ndelius-admin-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic ndelius admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_ndelius_elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow admins into the admin box
resource "aws_security_group_rule" "wnae_admin_elb_in" {
  from_port         = "${var.weblogic_domain_ports["ndelius_admin"]}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
  to_port           = "${var.weblogic_domain_ports["ndelius_admin"]}"
  type              = "ingress"
  cidr_blocks       = "${var.bastion_cidrs}"
}

resource "aws_security_group" "weblogic_ndelius_admin" {
  name        = "${local.environment_name}-weblogic-ndelius-admin"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic ndelius admin server"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_ndelius_admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow the ELB into the Admin port
resource "aws_security_group_rule" "wnae_admin_elb" {
  from_port                = "${var.weblogic_domain_ports["ndelius_admin"]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.weblogic_ndelius_admin.id}"
  to_port                  = "${var.weblogic_domain_ports["ndelius_admin"]}"
  type                     = "ingress"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
}

resource "aws_security_group" "weblogic_ndelius_managed" {
  name        = "${local.environment_name}-weblogic-ndelius-managed"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic ndelius managed servers"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_ndelius_managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

#Allow the ELB into the managed port
resource "aws_security_group_rule" "ndelius_elb" {
  security_group_id        = "${aws_security_group.weblogic_ndelius_managed.id}"
  type                     = "ingress"
  from_port                = "${var.weblogic_domain_ports["ndelius_managed"]}"
  to_port                  = "${var.weblogic_domain_ports["ndelius_managed"]}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
}
