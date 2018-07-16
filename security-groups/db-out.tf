resource "aws_security_group" "db_out" {
  name        = "${local.environment_name}-db-out"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Database out"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_db_out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "db_out" {
  security_group_id = "${aws_security_group.db_out.id}"
  type              = "egress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.db_in.id}"
}
