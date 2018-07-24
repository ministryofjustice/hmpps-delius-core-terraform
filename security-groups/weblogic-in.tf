# weblogic-master-in.tf

resource "aws_security_group" "weblogic_in" {
  name        = "${local.environment_name}-wls-mstr-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic master in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_wls_mstr_in", "Type", "WLS"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "weblogic-elb-in" {
  from_port         = 9704
  protocol          = "TCP"
  security_group_id = "${aws_security_group.weblogic_in.id}"
  to_port           = 9704
  type              = "ingress"
  cidr_blocks       = [
    "${data.aws_subnet.public_a.cidr_block}",
    "${data.aws_subnet.public_b.cidr_block}"
  ]
}
