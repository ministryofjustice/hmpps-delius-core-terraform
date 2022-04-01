resource "aws_security_group" "pre_sentence_report_lambda" {
  name        = "${var.environment_name}-pre-sentence-report-lambda"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Pre-sentence report handler lambda security group"
  tags        = merge(var.tags, { Name = "${var.environment_name}-pre-sentence-report-lambda" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_pre_sentence_report_lambda_id" {
  value = aws_security_group.pre_sentence_report_lambda.id
}

resource "aws_security_group_rule" "pre_sentence_report_lambda_to_delius_api" {
  security_group_id        = aws_security_group.pre_sentence_report_lambda.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.delius_api_lb.id
  description              = "Out to Delius API"
}
