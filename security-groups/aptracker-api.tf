resource "aws_security_group" "aptracker_api" {
  name        = "${var.environment_name}-ap-tracker-api"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Approved Premises Tracker API instances"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-ap-tracker-api"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_aptracker_api_id" {
  value = aws_security_group.aptracker_api.id
}

resource "aws_security_group_rule" "aptracker_instances_ingress_ndelius_lb" {
  security_group_id        = aws_security_group.aptracker_api.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = "8080"
  to_port                  = "8080"
  source_security_group_id = aws_security_group.weblogic_ndelius_lb.id
  description              = "WebLogic (ndelius) load balancer in"
}

resource "aws_security_group_rule" "aptracker_instances_egress_db" {
  security_group_id        = aws_security_group.aptracker_api.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = "1521"
  to_port                  = "1521"
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Database out"
}

