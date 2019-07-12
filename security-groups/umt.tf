################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "umt_lb" {
  name        = "${var.environment_name}-umt-lb"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "User Management Tool Load Balancer"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-umt-lb", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_umt_lb_id" {
  value = "${aws_security_group.umt_lb.id}"
}

# Allow NPS+CRC users into the external ELB
resource "aws_security_group_rule" "umt_lb_ingress" {
  security_group_id = "${aws_security_group.umt_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.user_access_cidr_blocks}"]
  description       = "Front-end users in"
}

resource "aws_security_group_rule" "umt_lb_ingress_tls" {
  security_group_id = "${aws_security_group.umt_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.user_access_cidr_blocks}"]
  description       = "Front-end users in (TLS)"
}

resource "aws_security_group_rule" "umt_lb_ingress_nat" {
  security_group_id = "${aws_security_group.umt_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.natgateway_public_ips_cidr_blocks}"]
  description       = "NAT gateway in"
}

resource "aws_security_group_rule" "umt_lb_ingress_nat_tls" {
  security_group_id = "${aws_security_group.umt_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.natgateway_public_ips_cidr_blocks}"]
  description       = "NAT gateway in (TLS)"
}

resource "aws_security_group_rule" "umt_lb_ingress_public_subnet" {
  security_group_id = "${aws_security_group.umt_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = ["${local.public_cidr_block}"]
  description       = "Public subnet in"
}

resource "aws_security_group_rule" "umt_lb_ingress_public_subnet_tls" {
  security_group_id = "${aws_security_group.umt_lb.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = ["${local.public_cidr_block}"]
  description       = "Public subnet in (TLS)"
}

resource "aws_security_group_rule" "umt_lb_egress_instance" {
  security_group_id        = "${aws_security_group.umt_lb.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.umt_instances.id}"
  description              = "Out to instances"
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

resource "aws_security_group_rule" "umt_instances_ingress_lb" {
  security_group_id        = "${aws_security_group.umt_instances.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.umt_lb.id}"
  description              = "Load balancer in"
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
