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
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.newtech_web.id
  description              = "In from New Tech UI"
}
