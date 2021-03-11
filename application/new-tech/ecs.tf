module "ecs" {
  source                 = "../../modules/ecs_service"
  region                 = var.region
  short_environment_name = var.short_environment_name
  tags                   = var.tags

  service_name = local.app_name

  # Security/Networking
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_new_tech_instances_id
  ]
  allowed_ssm_parameters = formatlist("arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter%s", values(local.secrets))
  ecs_cluster = {
    name         = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
    cluster_id   = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
    namespace_id = data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["id"]
  }

  # Auto-scaling
  required_cpu     = local.app_config["cpu"]
  required_memory  = local.app_config["memory"]
  min_capacity     = local.app_config["min_capacity"]
  max_capacity     = local.app_config["max_capacity"]
  target_cpu_usage = local.app_config["target_cpu"]

  # Application-specific configuration
  service_port                   = 9000
  lb_listener_arn                = data.terraform_remote_state.ndelius.outputs.lb_listener_arn
  lb_path_patterns               = ["/newTech", "/newTech/*"]
  health_check_path              = "/newTech/healthcheck"
  ignore_task_definition_changes = true # Deployment managed by CircleCI
  container_definition = jsonencode([{
    essential    = true
    name         = local.app_name
    image        = local.app_config["image_url"]
    cpu          = tonumber(local.app_config["cpu"])
    memory       = tonumber(local.app_config["memory"])
    portMappings = [{ hostPort = 9000, containerPort = 9000 }]
    environment  = [for key, value in local.environment : { name = key, value = value }]
    secrets      = [for key, value in local.secrets : { name = key, valueFrom = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${value}" }]
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

