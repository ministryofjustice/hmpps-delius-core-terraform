# Security groups

resource "aws_security_group" "weblogic_elb" {
  name        = "${local.environment_name}-weblogic-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "ELB"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_elb", "Type", "ELB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "weblogic-elb-http-in" {
  security_group_id = "${aws_security_group.weblogic_elb.id}"
  type              = "ingress"
  from_port         = 9704
  to_port           = 9704
  protocol          = "tcp"
  cidr_blocks       = ["${var.bastion_cidrs}"]
}

resource "aws_security_group_rule" "weblogic-elb-out" {
  security_group_id = "${aws_security_group.weblogic_elb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
