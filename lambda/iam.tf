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

# Provides minimum permissions for a Lambda function to execute while accessing a resource within a VPC - create, describe, delete network interfaces and write permissions to CloudWatch Logs.
data "aws_iam_policy" "AWSLambdaVPCAccessExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "sqs_consumer" {
  name               = "${var.environment_name}-sqs-consumer"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSLambdaSQSQueueExecutionRole.arn,
    data.aws_iam_policy.AWSLambdaVPCAccessExecutionRole.arn
  ]
  tags = merge(var.tags, { Name = "${var.environment_name}-sqs-consumer" })
}

output "sqs_consumer_lambda_exec_role" {
  value = {
    arn  = aws_iam_role.sqs_consumer.arn
    name = aws_iam_role.sqs_consumer.name
  }
}
