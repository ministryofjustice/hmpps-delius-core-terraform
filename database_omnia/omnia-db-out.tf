# omnia-db-out.tf

################################################################################
## omnia_db_out
################################################################################
resource "aws_security_group" "omnia_db_out" {
  name        = "${var.environment_name}-omnia-db-out"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "omnia database out"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-omnia-db-out"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_omnia_db_out_id" {
  value = aws_security_group.omnia_db_out.id
}

resource "aws_security_group_rule" "db_to_db_out" {
  security_group_id = aws_security_group.omnia_db_out.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = "5432"
  to_port           = "5432"
  self              = true
  description       = "Inter db comms"
}
