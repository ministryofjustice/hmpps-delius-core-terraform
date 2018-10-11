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
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "World in"
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
  from_port                = "${var.weblogic_domain_ports["oid_ldap"]}"
  to_port                  = "${var.weblogic_domain_ports["oid_ldap"]}"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed_elb.id}"
  description              = "OID LDAP out"
}

# This is a temp solution to enable quick access to yum repos from dev env
# during discovery.
resource "aws_security_group_rule" "ndelius_managed_egress_80" {
  count             = "${var.egress_80}"
  security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "yum repos"
}

# This is a temp solution to enable quick access to S3 bucket from dev env
# during discovery.
resource "aws_security_group_rule" "ndelius_managed_egress_443" {
  count             = "${var.egress_443}"
  security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "s3"
}
