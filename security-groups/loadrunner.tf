# loadrunner.tf

################################################################################
## loadrunner
################################################################################
resource "aws_security_group" "loadrunner" {
  name        = "${var.environment_name}-loadrunner"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Loadrunner instance SG"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-loadrunner"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_loadrunner_id" {
  value = aws_security_group.loadrunner.id
}

resource "aws_security_group_rule" "loadrunner_jenkins_ssh_ingress" {
  security_group_id = aws_security_group.loadrunner.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [data.terraform_remote_state.vpc.outputs.eng_vpc_cidr]
  description       = "Jenkins ssh in"
}

