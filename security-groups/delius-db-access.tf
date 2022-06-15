
resource "aws_security_group" "delius_db_access" {
  name        = "${var.environment_name}-delius-db-access"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Access to the Delius database"
  tags        = merge(var.tags, { Name = "${var.environment_name}-delius-db-access" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_db_access_id" {
  value = aws_security_group.delius_db_access.id
}

resource "aws_security_group_rule" "delius_db_access_to_db" {
  security_group_id        = aws_security_group.delius_db_access.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Out to Delius Database"
}
