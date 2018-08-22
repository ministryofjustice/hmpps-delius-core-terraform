# delius-db-in.tf

resource "aws_security_group" "delius_db_in" {
  name        = "${local.environment_name}-delius-db-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Database in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_delius_db_in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "weblogic_interface_managed_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_interface_admin_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_interface_admin.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_ndelius_managed_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_ndelius_admin_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_admin.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_spg_managed_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_spg_admin_db_in" {
  from_port                = "1521"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_spg_admin.id}"
  to_port                  = "1521"
  type                     = "ingress"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
}
