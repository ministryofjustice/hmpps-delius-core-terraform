locals {
  app_config = merge(var.common_ecs_scaling_config, var.default_delius_app_config, var.delius_app_config)
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

  dns_name   = "ndelius"
  app_name   = "weblogic-app"
  app_config = local.app_config

  security_groups_lb = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_ndelius_lb_id]
  security_groups_instances = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_ndelius_instances_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id
  ]

  health_check_path = var.dual_run_with_sr28 ? "/NDelius-war/delius/JSP/healthcheck.xhtml?ping" : "/NDelius-war/delius/JSP/healthcheck.jsp?ping"
  homepage_path     = var.dual_run_with_sr28 ? "/NDelius-war/delius/JSP/homepage.xhtml" : "/NDelius-war/delius/JSP/healthcheck.jsp?ping"
}

