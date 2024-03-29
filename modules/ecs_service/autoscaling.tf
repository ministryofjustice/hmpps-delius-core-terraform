resource "aws_appautoscaling_target" "scaling_target" {
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  resource_id        = "service/${data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name}/${aws_ecs_service.service.name}"
  role_arn           = aws_iam_role.exec.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # Use lifecycle rule as workaround for role_arn being changed every time due to
  # role_arn being required field but AWS will always switch this to the auto created service role
  lifecycle {
    ignore_changes = [role_arn]
  }
}

resource "aws_appautoscaling_policy" "cpu_scaling_policy" {
  count              = var.enable_cpu_scaling ? 1 : 0
  name               = "${local.name}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value     = var.target_cpu_usage
    disable_scale_in = var.disable_scale_in
  }
}

resource "aws_appautoscaling_policy" "mem_scaling_policy" {
  count              = var.enable_mem_scaling ? 1 : 0
  name               = "${local.name}-mem-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value     = var.target_mem_usage
    disable_scale_in = var.disable_scale_in
  }
}

