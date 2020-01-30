resource "aws_lambda_function" "notify_slack" {
  runtime          = "nodejs12.x"
  role             = "${data.aws_iam_role.lambda_exec_role.arn}"
  filename         = "${data.archive_file.lambda_handler_zip.output_path}"
  function_name    = "${local.lambda_name}"
  handler          = "notify-slack.handler"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda_handler_zip.output_path}"))}"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_slack.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.alarm_notification.arn}"
}