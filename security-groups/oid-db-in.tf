resource "aws_security_group" "oid_db_in" {
  name        = "${local.environment_name}-oid-db-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Database in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_oid_db_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "weblogic_oid_managed_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.oid_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_oid_admin_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_oid_admin.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.oid_db_in.id}"
}
