module "api" {
  source                 = "../../modules/ecs_service"
  region                 = var.region
  short_environment_name = var.short_environment_name
  tags                   = var.tags

  service_name         = local.api_name
  container_definition = data.template_file.api_container_definition.rendered
  required_cpu         = local.app_config["api_cpu"]
  required_memory      = local.app_config["api_memory"]
  max_capacity         = "1" # Fix to a single instance, as currently the batch processes cannot be scaled horizontally
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  lb_listener_arn      = data.terraform_remote_state.ndelius.outputs.lb_listener_arn
  lb_path_patterns     = ["/merge/api", "/merge/api/*"]
  health_check_path    = "/merge/api/actuator/health"

  ecs_cluster = {
    name         = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
    cluster_id   = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
    namespace_id = data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["id"]
  }

  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]

  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_merge_api_id,
  ]

  allowed_ssm_parameters = [
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/merge/db/admin_password",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/delius-database/db/delius_pool_password",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/merge/api/client_secret",
  ]
}

