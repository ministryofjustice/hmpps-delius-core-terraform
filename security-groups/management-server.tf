# management-server.tf

################################################################################
## management-server
################################################################################
resource "aws_security_group" "management_server" {
  name        = "${var.environment_name}-management"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Management instance SG"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-management", "Type", "Private"))}"
}

output "sg_management_id" {
  value = "${aws_security_group.management_server.id}"
}

resource "aws_security_group_rule" "management_delius_ldap_out" {
  security_group_id         = "${aws_security_group.management_server.id}"
  type                      = "egress"
  protocol                  = "tcp"
  from_port                 = "10389"
  to_port                   = "10389"
  source_security_group_id  = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description               = "Delius LDAP - LDAP out"
}

resource "aws_security_group_rule" "management_delius_db_out" {
  security_group_id         = "${aws_security_group.management_server.id}"
  type                      = "egress"
  protocol                  = "tcp"
  from_port                 = "1521"
  to_port                   = "1521"
  source_security_group_id  = "${aws_security_group.delius_db_in.id}"
  description               = "Delius database - DB out"
}
