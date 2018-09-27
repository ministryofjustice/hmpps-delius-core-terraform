# oid-db-out.tf

resource "aws_security_group" "oid_db_out" {
  name        = "${var.environment_name}-oid-db-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "OID Database out"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-oid-db-out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_oid_db_out_id" {
  value = "${aws_security_group.oid_db_out.id}"
}

## egress rules
# TODO resolve error
# aws_security_group_rule.oid_activemq_db_out: One of ['cidr_blocks', 'ipv6_cidr_blocks', 'self', 'source_security_group_id', 'prefix_list_ids'] must be set to create an AWS Security Group Rule
# WIP
# resource "aws_security_group_rule" "oid_activemq_db_out" {
#   security_group_id = "${aws_security_group.oid_db_out.id}"
#   type              = "egress"
#   protocol          = "tcp"
#   from_port         = "61616"
#   to_port           = "61617"
# }

# This is a temp solution to enable quick access to yum repos from dev env
# during discovery.
resource "aws_security_group_rule" "oid_db_egress_80" {
  count             = "${var.egress_80}"
  security_group_id = "${aws_security_group.oid_db_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

# This is a temp solution to enable quick access to S3 bucket from dev env
# during discovery.
resource "aws_security_group_rule" "oid_db_egress_443" {
  count             = "${var.egress_443}"
  security_group_id = "${aws_security_group.oid_db_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}
