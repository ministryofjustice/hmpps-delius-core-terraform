data "aws_iam_role" "delius_core_alerts" {
  name = "${var.environment_name}-delius-core-alerts-role"
}

data "archive_file" "lambda_source" {
    type = "zip"
    source_dir = "${path.module}/python/"
    output_path = "${path.module}/assets/ecs_task_retirement.zip"
}

resource "aws_lambda_layer_version" "slack_sdk" {
  layer_name          = "slack_sdk"
  compatible_runtimes = ["python3.9"]
  filename            = "${path.module}/assets/slack_sdk_layer.zip"
}

resource "aws_lambda_function" "task_retirement_lambda" {
  function_name = "${var.environment_name}-core-task-retirement-slack-alarm"
  description   = "Capture Task Retirement Events"
  handler       = "task_retirement.lambda_handler"
  runtime       = "python3.9"
  role          = data.aws_iam_role.delius_core_alerts.arn
  timeout       = 10

  filename         = data.archive_file.lambda_source.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_source.output_path)

  layers = [
    aws_lambda_layer_version.slack_sdk.arn
  ]

  environment {
    variables = {
      ENVIRONMENT   = var.environment_name
      SLACK_TOKEN   = "/alfresco/slack/token"
      SLACK_CHANNEL = "ask-probation-hosting"
    }
  }
}