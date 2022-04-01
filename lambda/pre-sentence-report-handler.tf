resource "aws_lambda_function" "pre_sentence_report_handler" {
  function_name = "${var.environment_name}-pre-sentence-report-handler"
  role          = aws_iam_role.cloud_platform_sqs_consumer.arn
  runtime       = local.python_runtime
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "pre-sentence-report-handler.zip"
  handler       = "main.handler"
  tags          = merge(var.tags, { Name = "${var.environment_name}-pre-sentence-report-handler" })
  vpc_config {
    security_group_ids = [
      data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
      data.terraform_remote_state.delius_core_security_groups.outputs.sg_pre_sentence_report_lambda_id
    ]
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
    ]
  }
}

# Handle notifications from the pre_sentence_report_hmpps_queue defined here: https://github.com/ministryofjustice/cloud-platform-environments/blob/main/namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-domain-events-dev/resources/hmpps-pre-sentence-report-queue.tf
resource "aws_lambda_event_source_mapping" "pre_sentence_report_handler" {
  count            = local.cp_namespace != "" ? 1 : 0
  function_name    = aws_lambda_function.pre_sentence_report_handler.function_name
  event_source_arn = "arn:aws:sqs:eu-west-2:754256621582:Digital-Prison-Services-${local.cp_namespace}-pre_sentence_report_hmpps_queue"
}
