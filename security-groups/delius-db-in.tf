# delius-db-in.tf

resource "aws_security_group" "delius_db_in" {
  name        = "${var.environment_name}-delius-db-in"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius database in"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-delius-db-in", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_db_in_id" {
  value = "${aws_security_group.delius_db_in.id}"
}

resource "aws_security_group_rule" "weblogic_interface_managed_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_interface_managed.id}"
}

resource "aws_security_group_rule" "weblogic_interface_admin_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_interface_admin.id}"
}

resource "aws_security_group_rule" "weblogic_ndelius_managed_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_managed.id}"
}

resource "aws_security_group_rule" "weblogic_ndelius_admin_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_admin.id}"
}

resource "aws_security_group_rule" "weblogic_spg_managed_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_spg_managed.id}"
}

resource "aws_security_group_rule" "weblogic_spg_admin_db_in" {
  security_group_id        = "${aws_security_group.delius_db_in.id}"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = "${aws_security_group.weblogic_spg_admin.id}"
}

# This is a temp solution to enable quick access to yum repos from dev env
# during discovery.
resource "aws_security_group_rule" "delius_db_egress_80" {
  count             = "${var.egress_80}"
  security_group_id = "${aws_security_group.delius_db_in.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "yum repos"
}

# This is a temp solution to enable quick access to S3 bucket from dev env
# during discovery.
resource "aws_security_group_rule" "delius_db_egress_443" {
  count             = "${var.egress_443}"
  security_group_id = "${aws_security_group.delius_db_in.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "s3"
}
