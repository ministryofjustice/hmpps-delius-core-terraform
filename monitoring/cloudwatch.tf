resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = "${data.template_file.delius_service_health_dashboard_file.rendered}"
}

module "ndelius_weblogic_alarms" {
  environment_name = "${var.environment_name}"
  source           = "modules/weblogic_alarms"
  tier_name        = "ndelius"
  asg_name         = "${data.terraform_remote_state.ndelius.asg["name"]}"
  loadbalancer_arn = "${data.terraform_remote_state.ndelius.alb["arn"]}"
  targetgroup_arn  = "${data.terraform_remote_state.ndelius.weblogic_targetgroup["arn"]}"
  action_arn       = "${aws_sns_topic.alarm_notification.arn}"
}

module "interface_weblogic_alarms" {
  environment_name = "${var.environment_name}"
  source           = "modules/weblogic_alarms"
  tier_name        = "interface"
  asg_name         = "${data.terraform_remote_state.interface.asg["name"]}"
  loadbalancer_arn = "${data.terraform_remote_state.interface.alb["arn"]}"
  targetgroup_arn  = "${data.terraform_remote_state.interface.weblogic_targetgroup["arn"]}"
  action_arn       = "${aws_sns_topic.alarm_notification.arn}"
}

module "spg_weblogic_alarms" {
  environment_name = "${var.environment_name}"
  source           = "modules/weblogic_alarms"
  tier_name        = "spg"
  asg_name         = "${data.terraform_remote_state.spg.asg["name"]}"
  loadbalancer_arn = "${data.terraform_remote_state.spg.alb["arn"]}"
  targetgroup_arn  = "${data.terraform_remote_state.spg.weblogic_targetgroup["arn"]}"
  action_arn       = "${aws_sns_topic.alarm_notification.arn}"
}

resource "aws_cloudwatch_metric_alarm" "response_time_warning_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-response-time-cwa--warning"
  alarm_description         = "NDelius front-end response time exceeded 1 second."
  namespace                 = "AWS/ApplicationELB"
  metric_name               = "TargetResponseTime"
  statistic                 = "Average"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1"
  evaluation_periods        = "1"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_critical_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-response-time-cwa--critical"
  alarm_description         = "NDelius front-end response time exceeded 5 seconds."
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Average"
  metric_name               = "TargetResponseTime"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "5"
  evaluation_periods        = "1"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_fatal_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-response-time-cwa--fatal"
  alarm_description         = "NDelius front-end response time exceeded 5 seconds for an extended period of time."
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Average"
  metric_name               = "TargetResponseTime"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "5"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "activemq_healthy_hosts_fatal_alarm" {
  alarm_name                = "${var.environment_name}-activemq-healthy-hosts-cwa--fatal"
  alarm_description         = "Healthy ActiveMQ instances dropped below 1, preventing SPG messages from being sent or received by NDelius."
  namespace                 = "AWS/ELB"
  statistic                 = "Minimum"
  metric_name               = "HealthyHostCount"
  comparison_operator       = "LessThanThreshold"
  threshold                 = "1"
  evaluation_periods        = "1"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    LoadBalancerName = "${data.terraform_remote_state.spg.jms_lb["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "inbound_queue_size_warning_alarm" {
  alarm_name                = "${var.environment_name}-activemq-inbound-queue-size-cwa--warning"
  alarm_description         = "Inbound queue size exceeded 25 for 30 minutes."
  namespace                 = "WebLogic"
  statistic                 = "Sum"
  metric_name               = "InboundQueueSize"
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = "25"
  evaluation_periods        = "30"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "inbound_queue_size_critical_alarm" {
  alarm_name                = "${var.environment_name}-activemq-inbound-queue-size-cwa--critical"
  alarm_description         = "Inbound queue size exceeded 100 for 3 hours."
  namespace                 = "WebLogic"
  statistic                 = "Sum"
  metric_name               = "InboundQueueSize"
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = "100"
  evaluation_periods        = "180"
  period                    = "60"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  insufficient_data_actions = ["${aws_sns_topic.alarm_notification.arn}"]
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
  }
}
