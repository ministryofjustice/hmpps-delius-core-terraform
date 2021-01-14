
################################################################################
## EFS File System
################################################################################
resource "aws_security_group" "activemq_efs" {
  name        = "${var.environment_name}-activemq-efs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "ActiveMQ EFS File System"
  tags = merge(var.tags, {
    Name = "${var.environment_name}-activemq-efs"
    Type = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_activemq_efs_id" {
  value = aws_security_group.activemq_efs.id
}

resource "aws_security_group_rule" "activemq_efs_instances_ingress" {
  security_group_id        = aws_security_group.activemq_efs.id
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.weblogic_spg_instances.id
  description              = "In from WebLogic SPG instances"
}

