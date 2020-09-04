resource "aws_cloudwatch_metric_alarm" "activemq_healthy_hosts_fatal_alarm" {
  alarm_name          = "${var.environment_name}-activemq-healthy-hosts-cwa--fatal"
  alarm_description   = "Healthy ActiveMQ instances dropped below 1, preventing SPG messages from being sent or received by NDelius."
  namespace           = "AWS/ELB"
  statistic           = "Minimum"
  metric_name         = "HealthyHostCount"
  comparison_operator = "LessThanThreshold"
  threshold           = "1"
  evaluation_periods  = "5"
  period              = "60"
  alarm_actions       = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions          = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    LoadBalancerName = "${data.terraform_remote_state.spg.jms_lb["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "inbound_queue_size_warning_alarm" {
  alarm_name          = "${var.environment_name}-activemq-inbound-queue-size-cwa--warning"
  alarm_description   = "Inbound queue size exceeded 30 for 30 minutes."
  namespace           = "WebLogic"
  statistic           = "Sum"
  metric_name         = "InboundQueueSize"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "30"
  evaluation_periods  = "30"
  period              = "60"
  alarm_actions       = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions          = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "inbound_queue_size_critical_alarm" {
  alarm_name          = "${var.environment_name}-activemq-inbound-queue-size-cwa--critical"
  alarm_description   = "Inbound queue size exceeded 100 for 3 hours."
  namespace           = "WebLogic"
  statistic           = "Sum"
  metric_name         = "InboundQueueSize"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "100"
  evaluation_periods  = "180"
  period              = "60"
  alarm_actions       = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions          = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "inbound_queue_rate_critical_alarm" {
  alarm_name          = "${var.environment_name}-activemq-inbound-queue-rate-cwa--critical"
  alarm_description   = "Inbound queue size increased at an elevated rate for over 10 minutes. Failover to standby may be required."
  comparison_operator = "GreaterThanThreshold"
  threshold           = "1"
  evaluation_periods  = "10"
  alarm_actions       = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions          = ["${aws_sns_topic.alarm_notification.arn}"]
  metric_query {
    id          = "e1"
    expression  = "RATE(m1)"
    label       = "InboundQueueRate"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      namespace   = "WebLogic"
      metric_name = "InboundQueueSize"
      stat        = "Sum"
      period      = 60
      dimensions {
        AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
      }
    }
  }
}
