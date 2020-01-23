################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "umt_auth" {
  name        = "${var.environment_name}-umt-auth"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius authentication via User Management Tool OAuth"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-umt-auth", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_umt_auth_id" {
  value = "${aws_security_group.umt_auth.id}"
}

resource "aws_security_group_rule" "umt_auth_egress_delius_lb" {
  security_group_id = "${aws_security_group.umt_auth.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.external_delius_lb_cidr_blocks}"]
  description       = "Delius load-balancers out (to access UMT auth server)"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "umt_instances" {
  name        = "${var.environment_name}-umt-instances"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "umt instances"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-umt-instances", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_umt_instances_id" {
  value = "${aws_security_group.umt_instances.id}"
}

resource "aws_security_group_rule" "umt_instances_ingress_ndelius_lb" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  description              = "WebLogic (ndelius) load balancer in"
}

resource "aws_security_group_rule" "umt_instances_ingress_spg_lb" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  description              = "WebLogic (spg) load balancer in"
}

resource "aws_security_group_rule" "umt_instances_ingress_interface_lb" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  description              = "WebLogic (interface) load balancer in"
}

resource "aws_security_group_rule" "umt_instances_egress_ldap" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAP out"
}

resource "aws_security_group_rule" "umt_instances_egress_db" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Database out"
}

resource "aws_security_group_rule" "umt_instances_egress_tokenstore" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "6379"
  to_port                  = "6379"
  source_security_group_id = "${aws_security_group.umt_tokenstore.id}"
  description              = "Token store out"
}

################################################################################
## Elasticache (token store)
################################################################################
resource "aws_security_group" "umt_tokenstore" {
  name        = "${var.environment_name}-umt-tokenstore"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "umt token store nodes"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-umt-tokenstore", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_umt_tokenstore_id" {
  value = "${aws_security_group.umt_tokenstore.id}"
}

resource "aws_security_group_rule" "umt_tokenstore_ingress_instances" {
  security_group_id        = "${aws_security_group.umt_tokenstore.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "6379"
  to_port                  = "6379"
  source_security_group_id = "${aws_security_group.umt_instances.id}"
  description              = "In from UMT instances"
}
