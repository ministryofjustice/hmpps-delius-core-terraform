resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = "${data.template_file.delius_service_health_dashboard_file.rendered}"
}

resource "aws_cloudwatch_metric_alarm" "response_time_warning_alarm" {
  alarm_name                = "${var.environment_name}-response-time-cwa--warning"
  alarm_description         = "NDelius front-end response time exceeded 1 second"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_critical_alarm" {
  alarm_name                = "${var.environment_name}-response-time-cwa--critical"
  alarm_description         = "NDelius front-end response time exceeded 5 seconds"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "5"
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_fatal_alarm" {
  alarm_name                = "${var.environment_name}-response-time-cwa--fatal"
  alarm_description         = "NDelius front-end response time exceeded 5 seconds for an extended period of time"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "5"
  insufficient_data_actions = []
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "5"
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_ndelius_cpu_util_warning_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-cpu-cwa--warning"
  alarm_description         = "WebLogic average CPU utilization exceeded 75% for the ndelius domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "75"
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.ndelius.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_ndelius_cpu_util_critical_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-cpu-cwa--critical"
  alarm_description         = "WebLogic average CPU utilization exceeded 90% for the ndelius domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "90"
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.ndelius.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_interface_cpu_util_warning_alarm" {
  alarm_name                = "${var.environment_name}-interface-cpu-cwa--warning"
  alarm_description         = "WebLogic average CPU utilization exceeded 75% for the interface domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "75"
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.interface.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_interface_cpu_util_critical_alarm" {
  alarm_name                = "${var.environment_name}-interface-cpu-cwa--critical"
  alarm_description         = "WebLogic average CPU utilization exceeded 90% for the interface domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "90"
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.interface.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_spg_cpu_util_warning_alarm" {
  alarm_name                = "${var.environment_name}-spg-cpu-cwa--warning"
  alarm_description         = "WebLogic average CPU utilization exceeded 75% for the spg domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "75"
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_spg_cpu_util_critical_alarm" {
  alarm_name                = "${var.environment_name}-spg-cpu-cwa--critical"
  alarm_description         = "WebLogic average CPU utilization exceeded 90% for the spg domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "90"
  dimensions {
    AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_ndelius_heap_usage_warning_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-heap-cwa--warning"
  alarm_description         = "WebLogic ASG average heap usage exceeded 75% for the ndelius domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  threshold                 = "75"
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
        AutoScalingGroupName = "${data.terraform_remote_state.ndelius.asg["name"]}"
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
        AutoScalingGroupName = "${data.terraform_remote_state.ndelius.asg["name"]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_ndelius_heap_usage_critical_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-heap-cwa--critical"
  alarm_description         = "WebLogic ASG average heap usage exceeded 90% for the ndelius domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  threshold                 = "90"
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
        AutoScalingGroupName = "${data.terraform_remote_state.ndelius.asg["name"]}"
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
        AutoScalingGroupName = "${data.terraform_remote_state.ndelius.asg["name"]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_interface_heap_usage_warning_alarm" {
  alarm_name                = "${var.environment_name}-interface-heap-cwa--warning"
  alarm_description         = "WebLogic ASG average heap usage exceeded 75% for the interface domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  threshold                 = "75"
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
        AutoScalingGroupName = "${data.terraform_remote_state.interface.asg["name"]}"
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
        AutoScalingGroupName = "${data.terraform_remote_state.interface.asg["name"]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_interface_heap_usage_critical_alarm" {
  alarm_name                = "${var.environment_name}-interface-heap-cwa--critical"
  alarm_description         = "WebLogic ASG average heap usage exceeded 90% for the interface domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  threshold                 = "90"
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
        AutoScalingGroupName = "${data.terraform_remote_state.interface.asg["name"]}"
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
        AutoScalingGroupName = "${data.terraform_remote_state.interface.asg["name"]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_spg_heap_usage_warning_alarm" {
  alarm_name                = "${var.environment_name}-spg-heap-cwa--warning"
  alarm_description         = "WebLogic ASG average heap usage exceeded 75% for the spg domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  threshold                 = "75"
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
        AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
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
        AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_spg_heap_usage_critical_alarm" {
  alarm_name                = "${var.environment_name}-spg-heap-cwa--critical"
  alarm_description         = "WebLogic ASG average heap usage exceeded 90% for the spg domain"
  alarm_actions             = ["${aws_sns_topic.alarm_notification.arn}"]
  ok_actions                = ["${aws_sns_topic.alarm_notification.arn}"]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  threshold                 = "90"
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
        AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
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
        AutoScalingGroupName = "${data.terraform_remote_state.spg.asg["name"]}"
      }
    }
  }
}
