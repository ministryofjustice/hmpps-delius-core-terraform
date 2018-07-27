# weblogic-in.tf

resource "aws_security_group" "weblogic_in" {
  name        = "${local.environment_name}-weblogic-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic master in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_in", "Type", "WLS"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "weblogic-elb-in" {
  security_group_id = "${aws_security_group.weblogic_in.id}"
  type              = "ingress"
  from_port         = 9704
  to_port           = 9704
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_elb.id}"
}
