# weblogic-ndelius.tf

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

# #Allow users into the managed boxes on the useful port
# #TODO: Do we build a list of allowed source in or?
# resource "aws_security_group_rule" "wnme_managed_elb_in" {
#   security_group_id = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
#   type              = "ingress"
#   protocol          = "tcp"
#   from_port         = "${var.weblogic_domain_ports["ndelius_managed"]}"
#   to_port           = "${var.weblogic_domain_ports["ndelius_managed"]}"
#   cidr_blocks       = ["0.0.0.0/0"]
# }
#
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

# #Allow admins into the admin box
# resource "aws_security_group_rule" "wnae_admin_elb_in" {
#   security_group_id = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
#   type              = "ingress"
#   protocol          = "tcp"
#   from_port         = "${var.weblogic_domain_ports["ndelius_admin"]}"
#   to_port           = "${var.weblogic_domain_ports["ndelius_admin"]}"
#   cidr_blocks       = "${var.bastion_cidrs}"
# }
#
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

# #Allow the ELB into the Admin port
# resource "aws_security_group_rule" "wnae_admin_elb" {
#   security_group_id        = "${aws_security_group.weblogic_ndelius_admin.id}"
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = "${var.weblogic_domain_ports["ndelius_admin"]}"
#   to_port                  = "${var.weblogic_domain_ports["ndelius_admin"]}"
#   source_security_group_id = "${aws_security_group.weblogic_ndelius_admin_elb.id}"
# }
#
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

# #Allow the ELB into the managed port
# resource "aws_security_group_rule" "ndelius_elb" {
#   security_group_id        = "${aws_security_group.weblogic_ndelius_managed.id}"
#   type                     = "ingress"
#   protocol                 = "tcp"
#   from_port                = "${var.weblogic_domain_ports["ndelius_managed"]}"
#   to_port                  = "${var.weblogic_domain_ports["ndelius_managed"]}"
#   source_security_group_id = "${aws_security_group.weblogic_ndelius_managed_elb.id}"
# }
