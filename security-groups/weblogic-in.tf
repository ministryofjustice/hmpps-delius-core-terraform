# weblogic-in.tf

resource "aws_security_group" "weblogic_in" {
  name        = "${local.environment_name}-weblogic-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic servers ingress"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_in", "Type", "WLS"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "weblogic_elb_in" {
  security_group_id = "${aws_security_group.weblogic_in.id}"
  type              = "ingress"
  from_port         = 9704
  to_port           = 9704
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_elb.id}"
}

resource "aws_security_group_rule" "weblogic_out_weblogic_in_7001_2" {
  security_group_id = "${aws_security_group.weblogic_in.id}"
  type              = "ingress"
  from_port         = 7001
  to_port           = 7002
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_out.id}"
}

resource "aws_security_group_rule" "weblogic_out_weblogic_in_7005" {
  security_group_id = "${aws_security_group.weblogic_in.id}"
  type              = "ingress"
  from_port         = 7005
  to_port           = 7005
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_out.id}"
}

resource "aws_security_group_rule" "db_out_weblogic_in" {
  security_group_id = "${aws_security_group.weblogic_in.id}"
  type              = "ingress"
  from_port         = 61616
  to_port           = 61617
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.db_out.id}"
}
