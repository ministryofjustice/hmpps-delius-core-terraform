# ECS role to allow reading from SQS queues
resource "aws_iam_role" "ecs_sqs_task" {
  name               = "${var.environment_name}-ecs-sqs-consumer"
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

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
      "kms:Encrypt",
      "kms:Decrypt",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sqs_policy" {
  name   = "${var.environment_name}-ecs-sqs-policy"
  policy = data.aws_iam_policy_document.sqs_policy.json
}

resource "aws_iam_role_policy_attachment" "sqs_policy_attachment" {
  role       = aws_iam_role.ecs_sqs_task.name
  policy_arn = aws_iam_policy.sqs_policy.arn
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
  name   = "${var.environment_name}-ecs-ssm-exec-policy"
  policy = data.aws_iam_policy_document.ssm_exec_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_exec_policy_attachment" {
  role       = aws_iam_role.ecs_sqs_task.name
  policy_arn = aws_iam_policy.ssm_exec_policy.arn
}
