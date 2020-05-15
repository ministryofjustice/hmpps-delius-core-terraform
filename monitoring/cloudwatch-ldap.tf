resource "aws_cloudwatch_metric_alarm" "ldap_cpu_warning_alarm" {
  alarm_name                = "${var.environment_name}-ldap-cpu-cwa--warning"
  alarm_description         = "LDAP average CPU utilization exceeded 75%."
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  metric_name               = "CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "75"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.ldap.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ldap_cpu_critical_alarm" {
  alarm_name                = "${var.environment_name}-ldap-cpu-cwa--critical"
  alarm_description         = "LDAP average CPU utilization exceeded 90%."
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  metric_name               = "CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "90"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.ldap.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ldap_healthy_hosts_fatal_alarm" {
  alarm_name                = "${var.environment_name}-ldap-healthy-hosts-cwa--fatal"
  alarm_description         = "All LDAP instances stopped responding."
  namespace                 = "AWS/ELB"
  statistic                 = "Minimum"
  metric_name               = "HealthyHostCount"
  comparison_operator       = "LessThanThreshold"
  threshold                 = "1"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    LoadBalancerName = "${data.terraform_remote_state.ldap.lb["name"]}"
  }
}
