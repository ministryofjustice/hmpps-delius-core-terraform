data "archive_file" "pre_sentence_report_handler" {
  type        = "zip"
  output_path = "${path.module}/files/pre-sentence-report-handler.zip"
  source {
    content  = file("${path.module}/lambda/pre-sentence-report-handler.py")
    filename = "lambda.py"
  }
}

resource "aws_lambda_function" "pre_sentence_report_handler" {
  function_name    = "${var.environment_name}-pre-sentence-report-handler"
  role             = aws_iam_role.lambda_exec_role.arn
  runtime          = "python3.8"
  handler          = "lambda.handler"
  filename         = data.archive_file.pre_sentence_report_handler.output_path
  source_code_hash = filebase64sha256(data.archive_file.pre_sentence_report_handler.output_path)
  tags             = merge(var.tags, { Name = "${var.environment_name}-pre-sentence-report-handler" })
}

resource "aws_lambda_event_source_mapping" "pre_sentence_report_handler" {
  count            = local.cp_namespace != "" ? 1 : 0
  function_name    = aws_lambda_function.pre_sentence_report_handler.function_name
  event_source_arn = "arn:aws:sqs:eu-west-2:754256621582:Digital-Prison-Services-${local.cp_namespace}-pre_sentence_report_hmpps_queue"
}
