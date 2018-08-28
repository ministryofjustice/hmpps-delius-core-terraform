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
  security_group_id        = "${aws_security_group.oid_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_oid_managed.id}"
}

resource "aws_security_group_rule" "weblogic_oid_admin_db_in" {
  security_group_id        = "${aws_security_group.oid_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_oid_admin.id}"  
}
