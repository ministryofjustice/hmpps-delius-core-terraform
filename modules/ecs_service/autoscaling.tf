resource "aws_appautoscaling_target" "scaling_target" {
  min_capacity       = "${var.min_capacity}"
  max_capacity       = "${var.max_capacity}"
  resource_id        = "service/${var.ecs_cluster["name"]}/${aws_ecs_service.service.name}"
  role_arn           = "${aws_iam_role.exec.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # Use lifecycle rule as workaround for role_arn being changed every time due to
  # role_arn being required field but AWS will always switch this to the auto created service role
  lifecycle {
    ignore_changes = "role_arn"
  }
}

resource "aws_appautoscaling_policy" "scaling_policy" {
  name                       = "${var.environment_name}-${var.service_name}-cpu-scaling-policy"
  policy_type                = "TargetTrackingScaling"
  resource_id                = "${aws_appautoscaling_target.scaling_target.resource_id}"
  scalable_dimension         = "${aws_appautoscaling_target.scaling_target.scalable_dimension}"
  service_namespace          = "${aws_appautoscaling_target.scaling_target.service_namespace}"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value             = "${var.target_cpu_usage}"
  }
}
