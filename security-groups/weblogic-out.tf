# weblogic-out.tf

resource "aws_security_group" "weblogic_out" {
  name        = "${local.environment_name}-weblogic-out"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic master out"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_out", "Type", "WLS"))}"

  lifecycle {
    create_before_destroy = true
  }
}

## egress rules
resource "aws_security_group_rule" "weblogic_out_db_in" {
  security_group_id = "${aws_security_group.weblogic_out.id}"
  type                      = "ingress"
  from_port                 = 1521
  to_port                   = 1521
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.db_in.id}"
}
