# oid-in.tf

resource "aws_security_group" "oid_in" {
  name        = "${local.environment_name}-oid-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "OID Weblogic master in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_oid_in", "Type", "OID"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "oid-elb-in" {
  from_port         = 3060
  protocol          = "TCP"
  security_group_id = "${aws_security_group.weblogic_in.id}"
  to_port           = 3060
  type              = "ingress"
  cidr_blocks       = [
    "${data.aws_subnet.public_a.cidr_block}",
    "${data.aws_subnet.public_b.cidr_block}"
  ]
}
