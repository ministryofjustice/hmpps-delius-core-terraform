# Task execution role for pulling the image, fetching secrets, and pushing logs to cloudwatch
resource "aws_iam_role" "exec" {
  name               = "${local.name}-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "exec_policy" {
  statement {
    sid    = "ECR"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Scaling"
    effect = "Allow"
    actions = [
      "application-autoscaling:*",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  dynamic "statement" {
    for_each = toset(aws_cloudwatch_log_group.log_group.*.arn)
    content {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ]
      resources = ["${statement.value}:*", "${statement.value}:log-stream:*"]
    }
  }
  dynamic "statement" {
    for_each = length(keys(var.secrets)) > 0 ? [""] : []
    content {
      sid       = "Parameters"
      effect    = "Allow"
      actions   = ["ssm:GetParameter", "ssm:GetParameters"]
      resources = formatlist(local.secrets_format, values(var.secrets))
    }
  }
}

resource "aws_iam_policy" "exec_policy" {
  name   = "${local.name}-ecs-exec-policy"
  policy = data.aws_iam_policy_document.exec_policy.json
}

resource "aws_iam_role_policy_attachment" "exec_policy_attachment" {
  role       = aws_iam_role.exec.name
  policy_arn = aws_iam_policy.exec_policy.arn
}

# Task role for the task to interact with AWS services
resource "aws_iam_role" "task" {
  name               = "${local.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "xray_logs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "xray_logs_policy" {
  count  = var.enable_telemetry ? 1 : 0
  name   = "${local.name}-ecs-xray-logs-policy"
  policy = data.aws_iam_policy_document.xray_logs_policy.json
}

resource "aws_iam_role_policy_attachment" "xray_logs_policy_attachment" {
  count      = var.enable_telemetry ? 1 : 0
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.xray_logs_policy.0.arn
}

resource "aws_iam_role_policy_attachment" "xray_policy_attachment" {
  count      = var.enable_telemetry ? 1 : 0
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

data "aws_iam_policy_document" "ssm_exec_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_exec_policy" {
  name   = "${local.name}-ecs-ssm-exec-policy"
  policy = data.aws_iam_policy_document.ssm_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_exec_policy_attachment" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.ssm_exec_policy.arn
}