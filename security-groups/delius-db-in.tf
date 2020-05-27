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

resource "aws_security_group_rule" "management_db_out" {
  security_group_id        = "${data.terraform_remote_state.network_security_groups.sg_management_server_id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "management_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.network_security_groups.sg_management_server_id}"
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

resource "aws_security_group_rule" "aptracker_api_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.aptracker_api.id}"
  description              = "Approved Premises Tracker API in"
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

resource "aws_security_group_rule" "eng_oem_db_in_22" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "22"
  to_port                  = "22"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.oem}"
  description              = "OEM in 22"
}

resource "aws_security_group_rule" "eng_oem_db_in_1521" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.oem}"
  description              = "OEM in 1521"
}

resource "aws_security_group_rule" "eng_oem_db_in_3872" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "3872"
  to_port                  = "3872"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.oem}"
  description              = "OEM in 3872"
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

# Allow Delius GDPR API in
resource "aws_security_group_rule" "gdpr_api_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.gdpr_api.id}"
  description              = "Delius GDPR API In"
}

# Allow CI (Jenkins/AWS CodePipeline) access to DB
resource "aws_security_group_rule" "eng_ci_db_in_1521" {
  count                    = "${var.ci_db_ingress_1521}"
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups_support_ci.sg_map_ids.ci_delius_db}"
  description              = "CI in 1521"
}
