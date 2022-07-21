resource "aws_lambda_function" "pre_sentence_report_handler" {
  function_name    = "${var.environment_name}-pre-sentence-report-handler"
  role             = aws_iam_role.sqs_consumer.arn
  runtime          = local.python_runtime
  filename         = data.archive_file.placeholder_python_package.output_path
  source_code_hash = data.archive_file.placeholder_python_package.output_base64sha256
  handler          = "main.handler"
  timeout          = 30 # seconds
  tags             = merge(var.tags, { Name = "${var.environment_name}-pre-sentence-report-handler" })

  environment {
    variables = {
      DELIUS_API_BASE_URL           = data.terraform_remote_state.delius_api.outputs.url
      PRE_SENTENCE_SERVICE_BASE_URL = local.pre_sentence_service_url
      OAUTH_BASE_URL                = local.oauth_base_url
      OAUTH_CLIENT_ID_PARAMETER     = aws_ssm_parameter.pre_sentence_report_client_id.name
      OAUTH_CLIENT_SECRET_PARAMETER = aws_ssm_parameter.pre_sentence_report_client_secret.name
    }
  }

  vpc_config {
    security_group_ids = [
      data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
      data.terraform_remote_state.delius_core_security_groups.outputs.sg_probation_integration_message_handler_id
    ]
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
    ]
  }

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
}

# Handle messages from the pre_sentence_report_hmpps_queue defined here: https://github.com/ministryofjustice/cloud-platform-environments/blob/main/namespaces/live.cloud-platform.service.justice.gov.uk/hmpps-domain-events-dev/resources/hmpps-pre-sentence-report-queue.tf
resource "aws_lambda_event_source_mapping" "pre_sentence_report_handler" {
  count            = local.cp_namespace != "" ? 1 : 0
  function_name    = aws_lambda_function.pre_sentence_report_handler.function_name
  event_source_arn = "arn:aws:sqs:eu-west-2:754256621582:Digital-Prison-Services-${local.cp_namespace}-pre_sentence_report_hmpps_queue"
}

# Placeholder parameters for the client credentials (these will be populated manually)
resource "aws_ssm_parameter" "pre_sentence_report_client_id" {
  name  = "/${var.environment_name}/${var.project_name}/probation-integration/pre-sentence-report-handler/client-id"
  value = "delius-pre-sentence-report-handler"
  type  = "String"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "pre_sentence_report_client_secret" {
  name  = "/${var.environment_name}/${var.project_name}/probation-integration/pre-sentence-report-handler/client-secret"
  value = "none"
  type  = "SecureString"
  lifecycle {
    ignore_changes = [value]
  }
}
