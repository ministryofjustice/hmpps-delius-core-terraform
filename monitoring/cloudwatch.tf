resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = "${data.template_file.delius_service_health_dashboard_file.rendered}"
}

resource "aws_cloudwatch_metric_alarm" "response_time_alarm" {
  alarm_name                = "${var.environment_name}-response-time-cwa"
  alarm_description         = "NDelius front-end response time exceeds 500ms"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  insufficient_data_actions = []
  metric_name               = "TargetResponseTime"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "0.5"
  dimensions {
    LoadBalancer = "${local.ndelius_alb_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "weblogic_ndelius_cpu_util_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-cpu-cwa"
  alarm_description         = "WebLogic ASG average CPU utilization exceeds 75% for the ndelius domain"
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

resource "aws_cloudwatch_metric_alarm" "weblogic_interface_cpu_util_alarm" {
  alarm_name                = "${var.environment_name}-interface-cpu-cwa"
  alarm_description         = "WebLogic ASG average CPU utilization exceeds 75% for the interface domain"
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

resource "aws_cloudwatch_metric_alarm" "weblogic_spg_cpu_util_alarm" {
  alarm_name                = "${var.environment_name}-spg-cpu-cwa"
  alarm_description         = "WebLogic ASG average CPU utilization exceeds 75% for the spg domain"
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

resource "aws_cloudwatch_metric_alarm" "weblogic_ndelius_heap_usage_alarm" {
  alarm_name                = "${var.environment_name}-ndelius-heap-cwa"
  alarm_description         = "WebLogic ASG average heap usage exceeds 75% for the ndelius domain"
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

resource "aws_cloudwatch_metric_alarm" "weblogic_interface_heap_usage_alarm" {
  alarm_name                = "${var.environment_name}-interface-heap-cwa"
  alarm_description         = "WebLogic ASG average heap usage exceeds 75% for the interface domain"
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

resource "aws_cloudwatch_metric_alarm" "weblogic_spg_heap_usage_alarm" {
  alarm_name                = "${var.environment_name}-spg-heap-cwa"
  alarm_description         = "WebLogic ASG average heap usage exceeds 75% for the spg domain"
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
