locals {
  alert_on_errors = toset(compact([
    var.environment_name != "delius-prod" ? "OASYSERR006" : null, // Invalid character in OASYS message (disabled in prod)
  ]))
}

# CloudWatch Logs Alarms
resource "aws_cloudwatch_log_metric_filter" "log_error_filter" {
  for_each       = local.alert_on_errors
  log_group_name = module.ecs.log_group["name"]
  name           = "${var.environment_name}-${var.app_name}-${each.value}-logged-errors"
  pattern        = each.value
  metric_transformation {
    name          = "${each.value}-LoggedErrors"
    namespace     = "${var.environment_name}/${var.app_name}"
    value         = 1
    default_value = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "log_error_alarm" {
  for_each            = local.alert_on_errors
  alarm_name          = "${var.environment_name}-${var.app_name}-logged-errors-${each.value}-cwa--warning"
  alarm_description   = "`${each.value}` errors were detected in the `${var.app_name}` logs."
  namespace           = aws_cloudwatch_log_metric_filter.log_error_filter[each.value].metric_transformation.0.namespace
  metric_name         = aws_cloudwatch_log_metric_filter.log_error_filter[each.value].metric_transformation.0.name
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  evaluation_periods  = 1
  period              = 300
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_max_util_warning_alarm" {
  alarm_name          = "${var.environment_name}-${var.app_name}-weblogic-max-cpu-cwa--critical"
  alarm_description   = "A WebLogic instance's CPU utilization reached 100%."
  namespace           = "AWS/ECS/ContainerInsights"
  statistic           = "Maximum"
  metric_name         = "CpuUtilized"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1000
  evaluation_periods  = 3
  period              = 300
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    ServiceName = module.ecs.service.name
    ClusterName = module.ecs.cluster.name
  }
}
