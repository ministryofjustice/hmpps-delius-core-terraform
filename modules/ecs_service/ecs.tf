resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${local.name}-task-definition"
  container_definitions    = var.container_definition
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.exec.arn
  network_mode             = "awsvpc"
  memory                   = var.required_memory
  cpu                      = var.required_cpu
  requires_compatibilities = ["EC2"]
  tags                     = merge(var.tags, { "Name" = "${local.name}-task-definition" })
}

resource "aws_ecs_service" "service" {
  name            = "${local.name}-service"
  cluster         = var.ecs_cluster["cluster_id"]
  task_definition = var.ignore_task_definition_changes && data.external.current_task_definition.result.arn != "" ? data.external.current_task_definition.result.arn : aws_ecs_task_definition.task_definition.arn

  deployment_controller {
    type = var.deployment_controller
  }

  health_check_grace_period_seconds = var.target_group_count > 0 ? var.health_check_grace_period_seconds : null

  dynamic "load_balancer" {
    for_each = toset(var.target_group_count > 0 ? [aws_lb_target_group.target_group.0.arn] : [])
    content {
      # Register this ECS service with the primary load balancer
      target_group_arn = load_balancer.value
      container_name   = var.service_name
      container_port   = var.service_port
    }
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.web_svc_record.arn
    container_name = var.service_name
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }

  depends_on = [aws_iam_role.task]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "web_svc_record" {
  name = var.service_name

  dns_config {
    namespace_id = var.ecs_cluster["namespace_id"]

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

