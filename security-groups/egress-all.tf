resource "aws_security_group" "egress_all" {
  name        = "${local.environment_name}-egress-all"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Egress all"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}-egress-all", "Type", "ALL"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress_all" {
  security_group_id = "${aws_security_group.egress_all.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
