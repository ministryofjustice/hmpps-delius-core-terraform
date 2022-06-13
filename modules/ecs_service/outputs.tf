output "service" {
  value = {
    id                     = aws_ecs_service.service.id
    name                   = aws_ecs_service.service.name
    task_definition_family = aws_ecs_task_definition.task_definition.family
  }
}

output "cluster" {
  value = {
    id   = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
    name = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
  }
}

output "primary_target_group" {
  value = length(aws_lb_target_group.target_group) == 0 ? {} : {
    id         = aws_lb_target_group.target_group.0.id
    arn        = aws_lb_target_group.target_group.0.arn
    arn_suffix = aws_lb_target_group.target_group.0.arn_suffix
    name       = aws_lb_target_group.target_group.0.name
  }
}

output "target_groups" {
  value = [for target_group in aws_lb_target_group.target_group : {
    id         = target_group.id
    arn        = target_group.arn
    arn_suffix = target_group.arn_suffix
    name       = target_group.name
  }]
}

output "task_role" {
  value = var.task_role_arn != "" ? {
    arn = var.task_role_arn
  } : {
    id   = aws_iam_role.task.id
    arn  = aws_iam_role.task.arn
    name = aws_iam_role.task.name
  }
}

output "log_group" {
  value = length(aws_cloudwatch_log_group.log_group) == 0 ? {} : {
    arn  = aws_cloudwatch_log_group.log_group.0.arn
    name = aws_cloudwatch_log_group.log_group.0.name
  }
}

output "autoscaling" {
  value = {
    resource_id        = aws_appautoscaling_target.scaling_target.resource_id
    scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
    service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace
  }
}