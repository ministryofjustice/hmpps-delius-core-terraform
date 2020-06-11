resource "aws_cloudwatch_metric_alarm" "healthy_hosts_warning_alarm" {
  alarm_name                = "${var.environment_name}-${var.tier_name}-weblogic-healthy-hosts-cwa--warning"
  alarm_description         = "One or more WebLogic instances in the `${var.tier_name}` domain stopped responding."
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Minimum"
  metric_name               = "UnHealthyHostCount"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${var.action_arn}"]
  ok_actions                = ["${var.action_arn}"]
  dimensions {
    LoadBalancer = "${local.lb_id}"
    TargetGroup = "${local.tg_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "healthy_hosts_fatal_alarm" {
  alarm_name                = "${var.environment_name}-${var.tier_name}-weblogic-healthy-hosts-cwa--fatal"
  alarm_description         = "All WebLogic instances in the `${var.tier_name}` domain stopped responding."
  namespace                 = "AWS/ApplicationELB"
  statistic                 = "Minimum"
  metric_name               = "HealthyHostCount"
  comparison_operator       = "LessThanThreshold"
  threshold                 = "1"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${var.action_arn}"]
  ok_actions                = ["${var.action_arn}"]
  dimensions {
    LoadBalancer = "${local.lb_id}"
    TargetGroup = "${local.tg_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_warning_alarm" {
  alarm_name                = "${var.environment_name}-${var.tier_name}-weblogic-cpu-cwa--warning"
  alarm_description         = "WebLogic average CPU utilization exceeded 75% for the `${var.tier_name}` domain."
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  metric_name               = "CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "75"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${var.action_arn}"]
  ok_actions                = ["${var.action_arn}"]
  dimensions {
    AutoScalingGroupName = "${var.asg_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_critical_alarm" {
  alarm_name                = "${var.environment_name}-${var.tier_name}-weblogic-cpu-cwa--critical"
  alarm_description         = "WebLogic average CPU utilization exceeded 90% for the `${var.tier_name}` domain."
  namespace                 = "AWS/EC2"
  statistic                 = "Average"
  metric_name               = "CPUUtilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "90"
  evaluation_periods        = "5"
  period                    = "60"
  alarm_actions             = ["${var.action_arn}"]
  ok_actions                = ["${var.action_arn}"]
  dimensions {
    AutoScalingGroupName = "${var.asg_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "heap_usage_warning_alarm" {
  alarm_name                = "${var.environment_name}-${var.tier_name}-weblogic-heap-cwa--warning"
  alarm_description         = "WebLogic average heap usage exceeded 75% for the `${var.tier_name}` domain."
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "75"
  evaluation_periods        = "5"
  alarm_actions             = ["${var.action_arn}"]
  ok_actions                = ["${var.action_arn}"]
  metric_query {
    id          = "e1"
    expression  = "100*(m2-m1)/m2"
    label       = "Heap Usage Percent"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      namespace   = "WebLogic"
      metric_name = "HeapFreeCurrent"
      period      = 60
      stat        = "Average"
      dimensions {
        AutoScalingGroupName = "${var.asg_name}"
      }
    }
  }
  metric_query {
    id = "m2"
    metric {
      namespace   = "WebLogic"
      metric_name = "HeapSizeMax"
      period      = 60
      stat        = "Average"
      dimensions {
        AutoScalingGroupName = "${var.asg_name}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "heap_usage_critical_alarm" {
  alarm_name                = "${var.environment_name}-${var.tier_name}-weblogic-heap-cwa--critical"
  alarm_description         = "WebLogic average heap usage exceeded 90% for the `${var.tier_name}` domain."
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "90"
  evaluation_periods        = "5"
  alarm_actions             = ["${var.action_arn}"]
  ok_actions                = ["${var.action_arn}"]
  metric_query {
    id          = "e1"
    expression  = "100*(m2-m1)/m2"
    label       = "Heap Usage Percent"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      namespace   = "WebLogic"
      metric_name = "HeapFreeCurrent"
      period      = 60
      stat        = "Average"
      dimensions {
        AutoScalingGroupName = "${var.asg_name}"
      }
    }
  }
  metric_query {
    id = "m2"
    metric {
      namespace   = "WebLogic"
      metric_name = "HeapSizeMax"
      period      = 60
      stat        = "Average"
      dimensions {
        AutoScalingGroupName = "${var.asg_name}"
      }
    }
  }
}