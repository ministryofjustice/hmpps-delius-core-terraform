locals {
  lambda_name         = "${var.environment_name}-${var.app_name}-nightly-restart"
  schedule_expression = "cron(15 02 * * ? *)" # 02:15 every day
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:UpdateService"]
    resources = [module.ecs.service["id"]]
  }
}

resource "aws_cloudwatch_event_rule" "rule" {
  name                = "${local.lambda_name}-rule"
  schedule_expression = local.schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.rule.name
  arn  = aws_lambda_function.nightly_restart_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.nightly_restart_lambda.function_name
  source_arn    = aws_cloudwatch_event_rule.rule.arn
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.lambda_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  description        = "Lambda execution role for the ${local.lambda_name} function"
  tags               = var.tags
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "${local.lambda_name}-exec-policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "nightly_restart_lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/files/nightly-restart-lambda.zip"
  source {
    content  = file("${path.module}/lambda/nightly-restart-lambda.py")
    filename = "lambda.py"
  }
}

resource "aws_lambda_function" "nightly_restart_lambda" {
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  handler          = "lambda.handler"
  filename         = data.archive_file.nightly_restart_lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.nightly_restart_lambda_zip.output_path)
  tags             = merge(var.tags, { Name = local.lambda_name })
  environment {
    variables = {
      CLUSTER       = module.ecs.cluster["name"]
      SERVICE       = module.ecs.service["name"]
      DESIRED_COUNT = var.app_config["min_capacity"]
    }
  }
}