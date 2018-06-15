# Security groups

resource "aws_security_group" "elb" {
  name        = "${local.environment_name}-elb"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "ELB"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_elb", "Type", "ELB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "elb_http_in" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${var.whitelist_cidrs}"]
}

resource "aws_security_group_rule" "elb_https_in" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.whitelist_cidrs}"]
}

resource "aws_security_group_rule" "elb_out" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
