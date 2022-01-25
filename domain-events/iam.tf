data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Provides receive message, delete message, and read attribute access to SQS queues, and write permissions to CloudWatch logs.
data "aws_iam_policy" "AWSLambdaSQSQueueExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role" "lambda_exec_role" {
  name               = "${var.environment_name}-cp-sqs-consumer"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSLambdaSQSQueueExecutionRole.arn
  ]
  tags = merge(var.tags, { Name = "${var.environment_name}-cp-sqs-consumer" })
}

output "lambda_exec_role" {
  value = {
    arn  = aws_iam_role.lambda_exec_role.arn
    name = aws_iam_role.lambda_exec_role.name
  }
}
