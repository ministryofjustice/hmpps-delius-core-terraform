locals {
  ndelius_alb_id = replace(module.ndelius.alb.id, "/.+:loadbalancer.{1}/", "")
}

# Front-end response time alarms
resource "aws_cloudwatch_metric_alarm" "response_time_warning_alarm" {
  alarm_name          = "${var.environment_name}-ndelius-response-time-cwa--warning"
  alarm_description   = "NDelius front-end response time exceeded 1 second."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"
  evaluation_periods  = "3"
  period              = "60"
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    LoadBalancer = local.ndelius_alb_id
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_critical_alarm" {
  alarm_name          = "${var.environment_name}-ndelius-response-time-cwa--critical"
  alarm_description   = "NDelius front-end response time exceeded 5 seconds."
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"
  metric_name         = "TargetResponseTime"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "5"
  evaluation_periods  = "3"
  period              = "60"
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    LoadBalancer = local.ndelius_alb_id
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_fatal_alarm" {
  alarm_name          = "${var.environment_name}-ndelius-response-time-cwa--fatal"
  alarm_description   = "NDelius front-end response time exceeded 5 seconds for an extended period of time."
  namespace           = "AWS/ApplicationELB"
  statistic           = "Average"
  metric_name         = "TargetResponseTime"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "5"
  evaluation_periods  = "5"
  period              = "60"
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    LoadBalancer = local.ndelius_alb_id
  }
}

