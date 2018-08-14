# db-in.tf

resource "aws_security_group" "db_in" {
  name        = "${local.environment_name}-db-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Database in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_db_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

## ingress rules
resource "aws_security_group_rule" "ingress_weblogic_out_db_in" {
  security_group_id = "${aws_security_group.db_in.id}"
  type              = "ingress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_out.id}"
}
