resource "aws_security_group" "new_tech_instances" {
  name        = "${var.environment_name}-new-tech-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "New Tech Web Service instances"
  tags        = merge(var.tags, { Name = "${var.environment_name}-new-tech-instances" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_new_tech_instances_id" {
  value = aws_security_group.new_tech_instances.id
}

resource "aws_security_group_rule" "new_tech_instances_in_from_ndelius_lb" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9000
  to_port                  = 9000
  security_group_id        = aws_security_group.new_tech_instances.id
  source_security_group_id = aws_security_group.weblogic_ndelius_lb.id
  description              = "In from NDelius Load Balancer"
}

resource "aws_security_group_rule" "new_tech_instances_out_to_pdf_generator" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  security_group_id        = aws_security_group.new_tech_instances.id
  source_security_group_id = aws_security_group.pdf_generator_instances.id
  description              = "Out to PDF Generator"
}
