locals {
  alarm_name = "${var.environment_name}-StatusCheckFailed-${module.delius_db_2.ami_id}"
}

resource "aws_cloudwatch_log_group" "ec2_status_check_log_group" {
  name              = "/metrics/${var.environment_name}/ec2-db-status-check-failed-${module.delius_db_2.ami_id}"
  retention_in_days = 0 # Retain indefinitely
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed_alarm" {
  alarm_name          = local.alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  actions_enabled     = true
  alarm_description   = "Alarm when the EC2 instance has failed the status check."
  dimensions = {
    InstanceId = module.delius_db_2.ami_id
  }
}

resource "aws_cloudwatch_event_rule" "ec2_status_check_failed_event" {
  name        = local.alarm_name
  description = "Rule to capture EC2 instance status check failures"
  event_pattern = jsonencode({
    "source" : ["aws.cloudwatch"],
    "detail-type" : ["CloudWatch Alarm State Change"],
    "detail" : {
      "state" : ["ALARM"],
      "alarmName" : ["${local.alarm_name}"]
    }
  })
}

resource "aws_cloudwatch_event_target" "ec2_status_check_failed_target" {
  rule      = aws_cloudwatch_event_rule.ec2_status_check_failed_event.name
  arn       = aws_cloudwatch_log_group.ec2_status_check_log_group.arn
  target_id = local.alarm_name
}

resource "aws_iam_role" "cloudwatch_event_role" {
  name = local.alarm_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "cloudwatch_event_policy" {
  name        = local.alarm_name
  description = "Policy to allow EventBridge to write to CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "logs:PutLogEvents"
      Effect   = "Allow"
      Resource = aws_cloudwatch_log_group.ec2_status_check_log_group.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_event_policy_attachment" {
  policy_arn = aws_iam_policy.cloudwatch_event_policy.arn
  role       = aws_iam_role.cloudwatch_event_role.name
}