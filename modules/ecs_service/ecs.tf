resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${local.name}-task-definition"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.exec.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = merge(var.tags, { Name = "${local.name}-task-definition" })

  # If a single container definition is provided, we instrument it with sensible defaults (e.g. logging to CloudWatch, port mapping)
  container_definitions = length(var.container_definitions) == 1 ? jsonencode([merge({
    name = var.service_name
    # Add CPU + Memory limits
    cpu    = tonumber(var.cpu)
    memory = tonumber(var.memory)
    # Add environment variables and secrets
    environment = [for key, value in var.environment : { name = key, value = value }]
    secrets     = [for key, value in var.secrets : { name = key, valueFrom = format(local.secrets_format, value) }]
    # Add default port mapping for service_port
    portMappings = [{ containerPort = var.service_port }]
    # Add default log configuration when none is provided
    logConfiguration = length(aws_cloudwatch_log_group.log_group) > 0 ? {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.log_group.0.name
        awslogs-region        = var.region
        awslogs-stream-prefix = var.service_name
      }
    } : null
  }, var.container_definitions[0])]) : jsonencode(var.container_definitions)
}

resource "aws_ecs_service" "service" {
  name            = "${local.name}-service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
  task_definition = var.ignore_task_definition_changes && data.external.current_task_definition.result.arn != "" ? data.external.current_task_definition.result.arn : aws_ecs_task_definition.task_definition.arn

  deployment_controller {
    type = var.deployment_controller
  }

  health_check_grace_period_seconds = var.target_group_count > 0 ? var.health_check_grace_period_seconds : null

  dynamic "load_balancer" {
    for_each = toset(var.target_group_count > 0 ? aws_lb_target_group.target_group.*.arn : [])
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
    subnets = [
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
    ]
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
    namespace_id = data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["id"]

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

