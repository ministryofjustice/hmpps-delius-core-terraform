# delius-db-out.tf

################################################################################
## delius_db_out
################################################################################
resource "aws_security_group" "delius_db_out" {
  name        = "${var.environment_name}-delius-db-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius database out"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-db-out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_db_out_id" {
  value = "${aws_security_group.delius_db_out.id}"
}

resource "aws_security_group_rule" "delius_db_out_spg_message" {
  security_group_id        = "${aws_security_group.delius_db_out.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  to_port                  = "${var.weblogic_domain_ports["activemq_port"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  description              = "Delius DB out to ActiveMQ"
}

resource "aws_security_group_rule" "db_to_db_out" {
  security_group_id = "${aws_security_group.delius_db_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  self              = true
  description       = "Inter db comms"
}

resource "aws_security_group_rule" "db_to_db_ssh_out" {
  security_group_id = "${aws_security_group.delius_db_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  self              = true
  description       = "Inter db ssh comms"
}

resource "aws_security_group_rule" "db_to_eng_rman_catalog_out" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.rman_catalog}"
  description              = "RMAN Catalog out"
}

resource "aws_security_group_rule" "eng_oem_db_out_4903" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "4903"
  to_port                  = "4903"
  source_security_group_id = "${data.terraform_remote_state.ora_db_op_security_groups.sg_map_ids.oem}"
  description              = "OEM out 4903"
}
