# weblogic-spg.tf

resource "aws_security_group" "weblogic_spg_managed_elb" {
  name        = "${var.environment_name}-weblogic-spg-managed-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-managed-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# #Allow users into the managed boxes on the useful port
# #TODO: Do we build a list of allowed source in or?
# resource "aws_security_group_rule" "wsme_managed_elb_in" {
#   security_group_id = "${aws_security_group.weblogic_spg_managed_elb.id}"
#   type              = "ingress"
#   protocol          = "tcp"
#   from_port         = "${var.weblogic_domain_ports["spg_managed"]}"
#   to_port           = "${var.weblogic_domain_ports["spg_managed"]}"
#   cidr_blocks       = ["0.0.0.0/0"]
# }
#
resource "aws_security_group" "weblogic_spg_admin_elb" {
  name        = "${var.environment_name}-weblogic-spg-admin-elb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-admin-elb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# #Allow admins into the admin box
# resource "aws_security_group_rule" "wsae_admin_elb_in" {
#   security_group_id = "${aws_security_group.weblogic_spg_admin_elb.id}"
#   type              = "ingress"
#   protocol          = "tcp"
#   from_port         = "${var.weblogic_domain_ports["spg_admin"]}"
#   to_port           = "${var.weblogic_domain_ports["spg_admin"]}"
#   cidr_blocks       = "${var.bastion_cidrs}"
# }
#
resource "aws_security_group" "weblogic_spg_admin" {
  name        = "${var.environment_name}-weblogic-spg-admin"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg admin server"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-admin", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# #Allow the ELB into the Admin port
# resource "aws_security_group_rule" "wsae_admin_elb" {
#   security_group_id        = "${aws_security_group.weblogic_spg_admin.id}"
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = "${var.weblogic_domain_ports["spg_admin"]}"
#   to_port                  = "${var.weblogic_domain_ports["spg_admin"]}"
#   source_security_group_id = "${aws_security_group.weblogic_spg_admin_elb.id}"
# }
#
resource "aws_security_group" "weblogic_spg_managed" {
  name        = "${var.environment_name}-weblogic-spg-managed"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Weblogic spg managed servers"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-weblogic-spg-managed", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# #Allow the ELB into the managed port
# resource "aws_security_group_rule" "spg_elb" {
#   security_group_id        = "${aws_security_group.weblogic_spg_managed.id}"
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = "${var.weblogic_domain_ports["spg_managed"]}"
#   to_port                  = "${var.weblogic_domain_ports["spg_managed"]}"
#   source_security_group_id = "${aws_security_group.weblogic_spg_managed_elb.id}"
# }
