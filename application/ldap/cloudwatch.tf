resource "aws_cloudwatch_metric_alarm" "ldap_cpu_warning_alarm" {
  alarm_name          = "${var.environment_name}-ldap-cpu-cwa--warning"
  alarm_description   = "LDAP CPU utilization exceeded 75%."
  namespace           = "AWS/EC2"
  statistic           = "Maximum"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "75"
  evaluation_periods  = "5"
  period              = "60"
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ldap_cpu_critical_alarm" {
  alarm_name          = "${var.environment_name}-ldap-cpu-cwa--critical"
  alarm_description   = "LDAP CPU utilization exceeded 90%."
  namespace           = "AWS/EC2"
  statistic           = "Maximum"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "90"
  evaluation_periods  = "5"
  period              = "60"
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ldap_healthy_hosts_fatal_alarm" {
  alarm_name          = "${var.environment_name}-ldap-healthy-hosts-cwa--fatal"
  alarm_description   = "All LDAP instances stopped responding."
  namespace           = "AWS/ELB"
  statistic           = "Minimum"
  metric_name         = "HealthyHostCount"
  comparison_operator = "LessThanThreshold"
  threshold           = "1"
  evaluation_periods  = "5"
  period              = "60"
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    LoadBalancerName = aws_elb.lb.name
  }
}

