# omnia-db-in.tf

################################################################################
## omnia_db_in
################################################################################
resource "aws_security_group" "omnia_db_in" {
  name        = "${var.environment_name}-omnia-db-in"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "omnia database in"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-omnia-db-in"
      "Type" = "DB"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_omnia_db_in_id" {
  value = aws_security_group.omnia_db_in.id
}

resource "aws_security_group_rule" "db_to_db_in" {
  security_group_id = aws_security_group.omnia_db_in.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "5444"
  to_port           = "5444"
  self              = true
  description       = "Inter db comms"
}
