
resource "aws_security_group" "aptracker_api" {
  name        = "${var.environment_name}-ap-tracker-api"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Approved Premises Tracker API instances"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-ap-tracker-api", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_aptracker_api_id" {
  value = "${aws_security_group.aptracker_api.id}"
}

resource "aws_security_group_rule" "umt_instances_ingress_ndelius_lb" {
  security_group_id        = "${aws_security_group.aptracker_api.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  description              = "WebLogic (ndelius) load balancer in"
}

resource "aws_security_group_rule" "umt_instances_ingress_spg_lb" {
  security_group_id        = "${aws_security_group.aptracker_api.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  description              = "WebLogic (spg) load balancer in"
}

resource "aws_security_group_rule" "umt_instances_ingress_interface_lb" {
  security_group_id        = "${aws_security_group.aptracker_api.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  description              = "WebLogic (interface) load balancer in"
}

resource "aws_security_group_rule" "umt_instances_egress_ldap" {
  security_group_id        = "${aws_security_group.aptracker_api.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "${var.ldap_ports["ldap"]}"
  to_port                  = "${var.ldap_ports["ldap"]}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  description              = "LDAP out"
}

resource "aws_security_group_rule" "umt_instances_egress_db" {
  security_group_id        = "${aws_security_group.aptracker_api.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Database out"
}
