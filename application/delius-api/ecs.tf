module "ecs" {
  source                 = "../../modules/ecs_service"
  region                 = var.region
  short_environment_name = var.short_environment_name
  tags                   = var.tags

  service_name           = local.app_name
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                = local.subnets.private
  security_groups        = local.security_groups.instances
  allowed_ssm_parameters = values(local.secrets)
  ecs_cluster = {
    name         = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
    cluster_id   = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
    namespace_id = data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["id"]
  }

  required_cpu      = local.app_config["cpu"]
  required_memory   = local.app_config["memory"]
  min_capacity      = local.app_config["min_capacity"]
  max_capacity      = local.app_config["max_capacity"]
  target_cpu_usage  = local.app_config["target_cpu"]
  health_check_path = "/health"

  container_definition = jsonencode([{
    essential    = true
    name         = local.app_name
    image        = "${local.app_config["image_url"]}:${aws_ssm_parameter.image_version.value}"
    cpu          = tonumber(local.app_config["cpu"])
    memory       = tonumber(local.app_config["memory"])
    portMappings = [{ hostPort = 8080, containerPort = 8080 }]
    environment  = [for key, value in local.environment : { name = key, value = value }]
    secrets      = [for key, valueFrom in local.secrets : { name = key, valueFrom = valueFrom }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.log_group.name
        awslogs-region        = var.region
        awslogs-stream-prefix = local.app_name
      }
    }
  }])
}

