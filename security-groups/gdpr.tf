######
# API
######

resource "aws_security_group" "gdpr_api" {
  name        = "${var.environment_name}-delius-gdpr-api-sg"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius GDPR API Security Group"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-gdpr-api-sg", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "gdpr_api_out_to_gdpr_db" {
  security_group_id        = "${aws_security_group.gdpr_api.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = "${aws_security_group.gdpr_db.id}"
  description              = "GDPR DB Out"
}

resource "aws_security_group_rule" "gdpr_api_out_to_delius_db" {
  security_group_id        = "${aws_security_group.gdpr_api.id}"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  description              = "Delius DB Out"
}

resource "aws_security_group_rule" "gdpr_api_in_from_ndelius_lb" {
  security_group_id        = "${aws_security_group.gdpr_api.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  description              = "WebLogic LB (ndelius) In"
}

resource "aws_security_group_rule" "gdpr_api_in_from_interface_lb" {
  security_group_id        = "${aws_security_group.gdpr_api.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  description              = "WebLogic LB (interface) In"
}

resource "aws_security_group_rule" "gdpr_api_in_from_spg_lb" {
  security_group_id        = "${aws_security_group.gdpr_api.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  description              = "WebLogic LB (spg) In"
}

output "sg_gdpr_api_id" {
  value = "${aws_security_group.gdpr_api.id}"
}

######
# UI
######

resource "aws_security_group" "gdpr_ui" {
  name        = "${var.environment_name}-delius-gdpr-ui-sg"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius GDPR UI Security Group"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-gdpr-ui-sg", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "gdpr_ui_in_from_ndelius_lb" {
  security_group_id        = "${aws_security_group.gdpr_ui.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  description              = "WebLogic LB (ndelius) In"
}

resource "aws_security_group_rule" "gdpr_ui_in_from_interface_lb" {
  security_group_id        = "${aws_security_group.gdpr_ui.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  description              = "WebLogic LB (interface) In"
}

resource "aws_security_group_rule" "gdpr_ui_in_from_spg_lb" {
  security_group_id        = "${aws_security_group.gdpr_ui.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  description              = "WebLogic LB (spg) In"
}

output "sg_gdpr_ui_id" {
  value = "${aws_security_group.gdpr_ui.id}"
}

######
# DB
######

resource "aws_security_group" "gdpr_db" {
  name        = "${var.environment_name}-delius-gdpr-db-sg"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius GDPR Database Security Group"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-gdpr-db-sg", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "gdpr_db_in_from_api" {
  security_group_id        = "${aws_security_group.gdpr_db.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = "${aws_security_group.gdpr_api.id}"
  description              = "GDPR API In"
}

resource "aws_security_group_rule" "gdpr_db_in_from_bastion" {
  security_group_id = "${aws_security_group.gdpr_db.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = ["${values(data.terraform_remote_state.vpc.bastion_vpc_public_cidr)}" ]
  description       = "Bastion In"
}

output "sg_gdpr_db_id" {
  value = "${aws_security_group.gdpr_db.id}"
}