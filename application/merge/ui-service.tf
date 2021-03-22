//module "ui" {
//  source                 = "../../modules/ecs_service"
//  region                 = var.region
//  short_environment_name = var.short_environment_name
//  tags                   = var.tags
//
//  service_name         = local.ui_name
//  service_port         = 80
//  container_definition = data.template_file.ui_container_definition.rendered
//  required_cpu         = local.app_config["ui_cpu"]
//  required_memory      = local.app_config["ui_memory"]
//  min_capacity         = local.app_config["ui_scaling_min_capacity"]
//  max_capacity         = local.app_config["ui_scaling_max_capacity"]
//  target_cpu_usage     = local.app_config["ui_target_cpu"]
//  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
//  lb_listener_arn      = data.terraform_remote_state.ndelius.outputs.lb_listener_arn
//  lb_path_patterns     = ["/gdpr/ui", "/gdpr/ui/*"]
//  health_check_path    = "/gdpr/ui/homepage"
//
//  ecs_cluster = {
//    name         = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
//    cluster_id   = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
//    namespace_id = data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["id"]
//  }
//
//  subnets = [
//    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
//    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
//    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
//  ]
//
//  security_groups = [
//    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id,
//    data.terraform_remote_state.delius_core_security_groups.outputs.sg_gdpr_ui_id,
//  ]
//}
//
