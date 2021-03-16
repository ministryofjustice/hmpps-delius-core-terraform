module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                      = local.app_name
  container_definitions             = [{ image = local.app_config["image_url"] }]
  health_check_path                 = "/health/ping"
  health_check_grace_period_seconds = 120
  ignore_task_definition_changes    = true # Deployment is managed by Circle CI
  environment = merge(local.environment, {
    SPRING_DATASOURCE_URL  = data.terraform_remote_state.database.outputs.jdbc_failover_url
    DELIUS_LDAP_USERS_BASE = data.terraform_remote_state.ldap.outputs.ldap_base_users
    SPRING_LDAP_USERNAME   = data.terraform_remote_state.ldap.outputs.ldap_bind_user
    SPRING_LDAP_URLS       = "${data.terraform_remote_state.ldap.outputs.ldap_protocol}://${data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.outputs.ldap_port}"
    ALFRESCO_BASEURL       = "https://alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}/alfresco/s/noms-spg"
    DELIUS_BASEURL         = "https://${data.terraform_remote_state.interface.outputs.private_fqdn_interface_wls_internal_alb}/api"
    # Add any environment variables here that should be pulled from Terraform data sources.
    # Other environment variables are managed by CircleCI. See https://github.com/ministryofjustice/community-api/blob/main/.circleci/config.yml
  })
  secrets = merge(local.secrets, {
    APPINSIGHTS_INSTRUMENTATIONKEY = "/${var.environment_name}/${var.project_name}/newtech/offenderapi/appinsights_key"
    SPRING_DATASOURCE_PASSWORD     = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_pool_password"
    SPRING_LDAP_PASSWORD           = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
    DELIUS_USERNAME                = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/casenotes_user"
    DELIUS_PASSWORD                = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/casenotes_password"
  })

  # Security & Networking
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_community_api_instances_id
  ]
  target_group_count = 2 # to support both the default and the public load balancer

  # Auto-Scaling
  cpu              = local.app_config["cpu"]
  memory           = local.app_config["memory"]
  min_capacity     = local.app_config["min_capacity"]
  max_capacity     = local.app_config["max_capacity"]
  target_cpu_usage = local.app_config["target_cpu"]
}

