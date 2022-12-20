locals {
  app_config = merge(var.common_ecs_scaling_config, var.default_delius_testdata_api_config, var.delius_testdata_api_config)
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

  dns_name   = "testdata-api"
  app_name   = "weblogic-testdata-api"
  app_config = local.app_config

  security_groups_lb = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_testdata_api_lb_id]
  security_groups_instances = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_testdata_api_instances_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id
  ]

  enable_response_time_alarms = false # Response times can exceed 1s during normal use, no need to alert
}

