# oid-db-out.tf

resource "aws_security_group" "oid_db_out" {
  name        = "${local.environment_name}-oid-db-out"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "OID Database out"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_oid_db_out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

## egress rules
# TODO resolve error
# aws_security_group_rule.oid_activemq_db_out: One of ['cidr_blocks', 'ipv6_cidr_blocks', 'self', 'source_security_group_id', 'prefix_list_ids'] must be set to create an AWS Security Group Rule
# WIP 
# resource "aws_security_group_rule" "oid_activemq_db_out" {
#   security_group_id = "${aws_security_group.oid_db_out.id}"
#   type              = "egress"
#   from_port         = "61616"
#   to_port           = "61617"
#   protocol          = "tcp"
# }
