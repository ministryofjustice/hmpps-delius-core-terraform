# oid-db-in.tf

resource "aws_security_group" "oid_db_in" {
  name        = "${var.environment_name}-oid-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "OID database in"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-oid-db-in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_oid_db_in_id" {
  value = "${aws_security_group.oid_db_in.id}"
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
