# weblogic-lb-out.tf

resource "aws_security_group" "weblogic_lb_out" {
  name        = "${local.environment_name}-weblogic-lb-out"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "ELB"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_lb_out", "Type", "LB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

## egress rules
resource "aws_security_group_rule" "weblogic_in_weblogic_lb_out" {
  security_group_id = "${aws_security_group.weblogic_lb_out.id}"
  type                      = "egress"
  from_port                 = 0
  to_port                   = 65535
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.weblogic_in.id}"
}
