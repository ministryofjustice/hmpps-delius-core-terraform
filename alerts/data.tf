data "aws_caller_identity" "current" {
}

data "archive_file" "alarm_lambda_handler_zip" {
  type        = "zip"
  output_path = "${path.module}/files/${local.lambda_name_alarm}.zip"
  source {
    content  = file("${path.module}/templates/lambda/notify-slack-alarm.js")
    filename = "notify-slack-alarm.js"
  }
}

data "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
}

data "archive_file" "batch_lambda_handler_zip" {
  type        = "zip"
  output_path = "${path.module}/files/${local.lambda_name_batch}.zip"
  source {
    content  = file("${path.module}/templates/lambda/notify-slack-batch.js")
    filename = "notify-slack-batch.js"
  }
}

