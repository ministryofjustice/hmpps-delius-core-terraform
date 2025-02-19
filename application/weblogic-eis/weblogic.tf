locals {
  app_config = merge(var.common_ecs_scaling_config, var.default_delius_eis_config, var.delius_eis_config)
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

  dns_name = "interface"
  app_name = "weblogic-eis"
  app_config = merge(local.app_config, {
    secret_ADMIN_PASSWORD = "/${var.environment_name}/${var.project_name}/weblogic/interface-domain/weblogic_admin_password"
  })

  security_groups_lb = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_interface_lb_id]
  security_groups_instances = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_interface_instances_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id
  ]

  health_check_grace_period_seconds = 600
  enable_response_time_alarms       = false # Response times can exceed 1s during normal use (e.g. during the daily DSS import)

  health_check_path = var.dual_run_with_sr28 ? "/NDelius-war/delius/javax.faces.resource/health/healthcheck.json" : "/NDelius-war/delius/JSP/healthcheck.jsp?ping"
  homepage_path     = var.dual_run_with_sr28 ? "/NDelius-war/delius/JSP/homepage.xhtml" : "/NDelius-war/delius/JSP/homepage.jsp"
}

