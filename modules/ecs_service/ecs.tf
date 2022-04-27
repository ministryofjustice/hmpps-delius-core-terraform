resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${local.name}-task-definition"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.exec.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = merge(var.tags, { Name = "${local.name}-task-definition" })

  dynamic "volume" {
    for_each = var.enable_telemetry ? ["xray-agent"] : []
    content {
      name      = volume.value
      host_path = "/${volume.value}"
    }
  }
  dynamic "volume" {
    for_each = var.enable_jmx_metrics ? ["jmx-exporter"] : []
    content {
      name      = volume.value
      host_path = "/${volume.value}"
    }
  }
  dynamic "volume" {
    for_each = local.additional_log_directories
    content {
      name = volume.value
    }
  }

  # If a single container definition is provided, we instrument it with sensible defaults (e.g. logging to CloudWatch, port mapping)
  container_definitions = length(var.container_definitions) == 1 ? jsonencode(concat(
    [
      merge({
        name = var.service_name
        # Set hard limit on memory
        memory = tonumber(var.memory)
        # Add environment variables and secrets
        environment = concat(
          [for key, value in var.environment : { name = key, value = value }],
          var.enable_telemetry ? [
            { name = "AWS_XRAY_TRACING_NAME", value = var.service_name },
            { name = "OTEL_RESOURCE_ATTRIBUTES", value = "service.name=${var.service_name},service.namespace=${var.environment_name}" },
          ] : [],
          local.java_tool_options != "" ? [
            { name = "JAVA_TOOL_OPTIONS", value = local.java_tool_options }
          ] : [],
        )
        secrets = [for key, value in var.secrets : { name = key, valueFrom = format(local.secrets_format, value) }]
        # Add default port mapping for service_port
        portMappings = concat(
          [{ containerPort = var.service_port }],
          var.enable_jmx_metrics ? [{ containerPort = local.jmx_exporter_port }] : []
        )
        mountPoints = concat(
          # Mount volumes to push additional log files via sidecar containers
          [for directory, name in local.additional_log_directories : {
            sourceVolume  = name
            containerPath = directory
          }],
          # Mount volume to access the AWS OpenTelemetry Agent
          var.enable_telemetry ? [{
            sourceVolume  = "xray-agent"
            containerPath = "/xray-agent"
            readOnly      = true
          }] : [],
          # Mount volume to access the Prometheus JMX Exporter
          var.enable_jmx_metrics ? [{
            sourceVolume  = "jmx-exporter"
            containerPath = "/jmx-exporter"
            readOnly      = true
          }] : [],
        )
        # Add default log configuration when none is provided
        logConfiguration = length(aws_cloudwatch_log_group.log_group) > 0 ? {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.log_group.0.name
            awslogs-region        = var.region
            awslogs-stream-prefix = "ecs"
          }
        } : null
      }, var.container_definitions[0])
    ],
    # Sidecar container for the AWS OpenTelemetry Collector, used for collecting metrics and/or traces
    var.enable_telemetry || var.enable_jmx_metrics ? [{
      name  = "aws-otel-collector"
      image = "public.ecr.aws/aws-observability/aws-otel-collector",
      environment = [
        { name = "AWS_REGION", value = var.region },
        { name = "AOT_CONFIG_CONTENT", value = templatefile("${path.module}/adot-config.yml", {
          cluster_name           = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
          service_name           = "${local.name}-service"
          task_definition_family = "${local.name}-task-definition"
        }) }
      ]
      portMappings = [
        { containerPort = 2000, hostPort = 2000, protocol = "udp" },   # AWS X-ray
        { containerPort = 4317, hostPort = 4317, protocol = "tcp" },   # AWS Open Telemetry collector (gRPC)
        { containerPort = 55681, hostPort = 55681, protocol = "tcp" }, # AWS Open Telemetry collector (HTTP)
      ]
      logConfiguration = length(aws_cloudwatch_log_group.log_group) > 0 ? {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log_group.0.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      } : null
    }] : [],
    # Sidecar containers for pushing additional log files to CloudWatch:
    [for name, path in var.additional_log_files : {
      name    = name
      image   = "public.ecr.aws/amazonlinux/amazonlinux:2"
      user    = "root"
      command = ["/bin/sh", "-c", "while [ ! -f '${path}' ]; do sleep 1; done && tail -n+1 -F '${path}'"]
      mountPoints = [{
        sourceVolume  = name
        containerPath = dirname(path)
        readOnly      = true
      }]
      dependsOn = [{
        containerName = var.service_name,
        condition     = "START"
      }]
      logConfiguration = length(aws_cloudwatch_log_group.log_group) > 0 ? {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log_group.0.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      } : null
    }])
  ) : jsonencode(var.container_definitions)
}

resource "aws_ecs_service" "service" {
  name                              = "${local.name}-service"
  cluster                           = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
  enable_execute_command            = true
  health_check_grace_period_seconds = var.target_group_count > 0 ? var.health_check_grace_period_seconds : null
  task_definition                   = var.ignore_task_definition_changes && data.external.current_task_definition.result.arn != "" ? data.external.current_task_definition.result.arn : aws_ecs_task_definition.task_definition.arn

  capacity_provider_strategy {
    capacity_provider = data.terraform_remote_state.ecs_cluster.outputs.capacity_provider["name"]
    weight            = 1
  }

  deployment_controller {
    type = var.deployment_controller
  }

  dynamic "load_balancer" {
    for_each = toset(var.target_group_count > 0 ? aws_lb_target_group.target_group.*.arn : [])
    content {
      # Register this ECS service with the primary load balancer
      target_group_arn = load_balancer.value
      container_name   = var.service_name
      container_port   = var.service_port
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.placement_strategy
    content {
      field = ordered_placement_strategy.value.field
      type  = ordered_placement_strategy.value.type
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

