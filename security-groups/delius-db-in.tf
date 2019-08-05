# delius-db-in.tf

################################################################################
## delius_db_in
################################################################################
resource "aws_security_group" "delius_db_in" {
  name        = "${var.environment_name}-delius-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius database in"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-db-in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_db_in_id" {
  value = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_interface_admin_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_interface_instances.id}"
  description              = "wls interface instances in"
}

resource "aws_security_group_rule" "weblogic_ndelius_admin_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_instances.id}"
  description              = "wls ndelius instances in"
}

resource "aws_security_group_rule" "weblogic_spg_admin_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_spg_instances.id}"
  description              = "wls spg instances in"
}

resource "aws_security_group_rule" "db_to_db_in" {
  security_group_id = "${aws_security_group.delius_db_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  self              = true
  description       = "Inter db comms"
}

resource "aws_security_group_rule" "db_to_db_ssh_in" {
  security_group_id = "${aws_security_group.delius_db_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  self              = true
  description       = "Inter db ssh comms"
}

resource "aws_security_group_rule" "management_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.management_server.id}"
  description              = "Management server in"
}

resource "aws_security_group_rule" "umt_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.umt_instances.id}"
  description              = "User Management Tool in"
}

resource "aws_security_group_rule" "eng_rman_catalog_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.rman_catalog}"
  description              = "RMAN Catalog in"
}

# Allow New Tech Offender API In
resource "aws_security_group_rule" "newtech_offender_api_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.newtech_offenderapi_out.id}"
  description              = "New Tech Offender API In"
}
