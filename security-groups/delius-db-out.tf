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
  from_port                = "${var.weblogic_domain_ports["spg_jms_broker"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_admin.id}"
  description              = "Delius db out SPG JMS Broker"
}

resource "aws_security_group_rule" "delius_db_out_spg_message_elb" {
  security_group_id        = "${aws_security_group.delius_db_out.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.weblogic_domain_ports["spg_jms_broker"]}"
  to_port                  = "${var.weblogic_domain_ports["spg_jms_broker_ssl"]}"
  source_security_group_id = "${aws_security_group.weblogic_spg_admin_elb.id}"
  description              = "Delius db out SPG JMS Broker"
}
