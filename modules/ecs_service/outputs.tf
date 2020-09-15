output "service" {
  value = {
    id   = aws_ecs_service.service.id
    name = aws_ecs_service.service.name
  }
}

output "target_group" {
  value = {
    id   = aws_lb_target_group.target_group.id
    arn  = aws_lb_target_group.target_group.arn
    name = aws_lb_target_group.target_group.name
  }
}

output "task_role" {
  value = {
    id   = aws_iam_role.task.id
    arn  = aws_iam_role.task.arn
    name = aws_iam_role.task.name
  }
}

