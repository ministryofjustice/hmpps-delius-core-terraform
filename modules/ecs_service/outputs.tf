output "service" {
  value = {
    id   = aws_ecs_service.service.id
    name = aws_ecs_service.service.name
  }
}

output "primary_target_group" {
  value = {
    id   = aws_lb_target_group.target_group.0.id
    arn  = aws_lb_target_group.target_group.0.arn
    name = aws_lb_target_group.target_group.0.name
  }
}

output "target_groups" {
  value = [for target_group in aws_lb_target_group.target_group : {
    id   = target_group.id
    arn  = target_group.arn
    name = target_group.name
  }]
}

output "task_role" {
  value = {
    id   = aws_iam_role.task.id
    arn  = aws_iam_role.task.arn
    name = aws_iam_role.task.name
  }
}

