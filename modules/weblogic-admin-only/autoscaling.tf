resource "aws_appautoscaling_policy" "heap_scaling_out_policy" {
  name               = "${var.short_environment_name}-${var.app_name}-heap-scale-out-policy"
  policy_type        = "StepScaling"
  resource_id        = module.ecs.autoscaling["resource_id"]
  scalable_dimension = module.ecs.autoscaling["scalable_dimension"]
  service_namespace  = module.ecs.autoscaling["service_namespace"]

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    metric_aggregation_type = "Average"
    cooldown                = 600
    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "heap_scaling_up_alarm" {
  alarm_name          = "${var.short_environment_name}-${var.app_name}-heap-scale-out-alarm"
  alarm_description   = "WebLogic heap usage percentage above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  threshold           = 80 # Scale up above 80% heap usage
  alarm_actions       = [aws_appautoscaling_policy.heap_scaling_out_policy.arn]

  metric_query {
    id          = "e1"
    expression  = "100 * m1 / m2"
    label       = "Heap Usage Percent"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      namespace   = "ECS/ContainerInsights/Prometheus"
      metric_name = "jvm_memory_bytes_used"
      stat        = "Average"
      period      = 60
      dimensions = {
        ClusterName          = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
        TaskDefinitionFamily = "${var.short_environment_name}-${var.app_name}-task-definition"
        area                 = "heap"
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      namespace   = "ECS/ContainerInsights/Prometheus"
      metric_name = "jvm_memory_bytes_max"
      stat        = "Average"
      period      = 60
      dimensions = {
        ClusterName          = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
        TaskDefinitionFamily = "${var.short_environment_name}-${var.app_name}-task-definition"
        area                 = "heap"
      }
    }
  }
}
