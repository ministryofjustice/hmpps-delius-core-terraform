resource "aws_ecs_task_definition" "scheduled_task_definition" {
  for_each                 = var.scheduled_tasks

  family                   = "${local.name}-${each.key}-scheduled-task-definition"
  task_role_arn            = var.task_role_arn != "" ? var.task_role_arn : aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.exec.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  tags                     = merge(var.tags, { Name = "${local.name}-${each.key}-scheduled-task-definition" })

  container_definitions = jsonencode([{
    name    = each.key
    image   = "public.ecr.aws/docker/library/busybox" # dummy config, will be overwritten by the task definition template in the project
    logConfiguration = length(aws_cloudwatch_log_group.log_group) > 0 ? {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.log_group.0.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs-scheduled-task"
      }
    } : null
  }])
}

resource "aws_cloudwatch_event_rule" "scheduled_task_event_rule" {
  for_each            = var.scheduled_tasks
  name_prefix         = "ecs"
  description         = "Event rule for scheduled ECS task ${local.name}-${each.key}"
  schedule_expression = each.value.schedule_expression
  tags                = merge(var.tags, { Name = "${local.name}-${each.key}-scheduled-task-event-rule" })
}

resource "aws_cloudwatch_event_target" "scheduled_task_event_target" {
  for_each = var.scheduled_tasks
  arn      = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
  rule     = aws_cloudwatch_event_rule.scheduled_task_event_rule[each.key].name
  role_arn = aws_iam_role.events.0.arn
  ecs_target {
    group                  = "${local.name}-${each.key}"
    task_definition_arn    = aws_ecs_task_definition.scheduled_task_definition[each.key].arn
    launch_type            = "EC2"
    enable_execute_command = true
    network_configuration {
      subnets = [
        data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
        data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
        data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
      ]
      security_groups = concat(
        var.security_groups,
        [ for sg in aws_security_group.scheduled_task_security_group : sg.id ]
      )
    }
  }
  lifecycle {
    ignore_changes = [ecs_target[0].task_definition_arn] # Currently this is always managed externally. This will need extra work if we ever want to fully define the task definition in Terraform, but it's unlikely that we'll ever do that.
  }
}

resource "aws_security_group" "scheduled_task_security_group" {
  for_each    = var.scheduled_tasks
  name        = "${local.name}-${each.key}-scheduled-task-security-group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Access to the ${local.name} ECS service from the ${each.key} scheduled task"
  tags        = merge(var.tags, { Name = "${local.name}-${each.key}-scheduled-task-security-group" })
  ingress {
    from_port = var.service_port
    to_port   = var.service_port
    protocol  = "tcp"
    self      = true
  }
  egress {
    from_port = var.service_port
    to_port   = var.service_port
    protocol  = "tcp"
    self      = true
  }
}
