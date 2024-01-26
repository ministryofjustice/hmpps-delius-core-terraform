locals {
  app_config = merge(var.common_ecs_scaling_config, var.default_delius_SR28_config, var.delius_SR28_config)
}

module "weblogic" {
  source                   = "../../modules/weblogic-admin-only"
  region                   = var.region
  environment_name         = var.environment_name
  project_name             = var.project_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  delius_core_public_zone  = var.delius_core_public_zone
  tags                     = var.tags

  dns_name   = "ndelius-sr28"
  app_name   = "weblogic-SR28"
  app_config = local.app_config

  security_groups_lb = [aws_security_group.weblogic_SR28_lb.id]
  security_groups_instances = [
    aws_security_group.weblogic_SR28_instances.id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id
  ]

  enable_response_time_alarms = false # Response times can exceed 1s during normal use, no need to alert
  health_check_path = "/"
  health_check_matcher = "200-499"
}

