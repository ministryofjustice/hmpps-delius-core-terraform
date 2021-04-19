resource "aws_security_group" "pdf_generator_instances" {
  name        = "${var.environment_name}-pdf-generator-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "PDF Generator instances"
  tags        = merge(var.tags, { Name = "${var.environment_name}-pdf-generator-instances" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_pdf_generator_instances_id" {
  value = aws_security_group.pdf_generator_instances.id
}

resource "aws_security_group_rule" "pdf_generator_instances_from_new_tech" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  security_group_id        = aws_security_group.pdf_generator_instances.id
  source_security_group_id = aws_security_group.new_tech_instances.id
  description              = "In from New Tech Web Service"
}
