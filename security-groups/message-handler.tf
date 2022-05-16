# Shared security group for Probation Integration message handlers.
# If additional rules are needed for a specific function, then an additional security group should be created for it.

resource "aws_security_group" "probation_integration_message_handler" {
  name        = "${var.environment_name}-probation-integration-message-handler"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Shared security group for Probation Integration message handlers."
  tags        = merge(var.tags, { Name = "${var.environment_name}-probation-integration-message-handler" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_probation_integration_message_handler_id" {
  value = aws_security_group.probation_integration_message_handler.id
}

resource "aws_security_group_rule" "probation_integration_lambda_to_delius_api" {
  security_group_id        = aws_security_group.probation_integration_message_handler.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.delius_api_lb.id
  description              = "Out to Delius API"
}
