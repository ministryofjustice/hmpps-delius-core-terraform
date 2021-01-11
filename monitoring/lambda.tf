resource "aws_lambda_function" "notify_slack_alarm" {
  runtime          = "nodejs12.x"
  role             = data.aws_iam_role.lambda_exec_role.arn
  filename         = data.archive_file.alarm_lambda_handler_zip.output_path
  function_name    = local.lambda_name_alarm
  handler          = "notify-slack-alarm.handler"
  source_code_hash = filebase64sha256(data.archive_file.alarm_lambda_handler_zip.output_path)
  environment {
    variables = {
      ENABLED                 = tostring(var.delius_alarms_config.enabled)
      ENVIRONMENT_NAME        = var.environment_name
      QUIET_PERIOD_START_HOUR = tostring(var.delius_alarms_config.quiet_hours[0])
      QUIET_PERIOD_END_HOUR   = tostring(var.delius_alarms_config.quiet_hours[1])
      SLACK_CHANNEL           = var.environment_name == "delius-prod" ? "delius-alerts-deliuscore-production" : "delius-alerts-deliuscore-nonprod"
    }
  }
}

resource "aws_lambda_permission" "sns_alarm" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_slack_alarm.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_notification.arn
}

resource "aws_lambda_function" "notify_slack_batch" {
  runtime          = "nodejs12.x"
  role             = data.aws_iam_role.lambda_exec_role.arn
  filename         = data.archive_file.batch_lambda_handler_zip.output_path
  function_name    = local.lambda_name_batch
  handler          = "notify-slack-batch.handler"
  source_code_hash = filebase64sha256(data.archive_file.batch_lambda_handler_zip.output_path)
  environment {
    variables = {
      ENABLED                 = tostring(var.delius_alarms_config.enabled)
      ENVIRONMENT_NAME        = var.environment_name
      QUIET_PERIOD_START_HOUR = tostring(var.delius_alarms_config.quiet_hours[0])
      QUIET_PERIOD_END_HOUR   = tostring(var.delius_alarms_config.quiet_hours[1])
      SLACK_CHANNEL           = var.environment_name == "delius-prod" ? "delius-alerts-deliuscore-production" : "delius-alerts-deliuscore-nonprod"
    }
  }
}

resource "aws_lambda_permission" "sns_batch" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notify_slack_batch.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.batch_notification.arn
}

