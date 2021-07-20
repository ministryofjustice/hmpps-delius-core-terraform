module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                   = local.app_name
  service_port                   = 9000
  container_definitions          = [{ image = local.app_config["image_url"] }]
  ignore_task_definition_changes = true # Deployment is managed by Circle CI
  environment = merge({ for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }, {
    LDAP_STRING_FORMAT = "cn=%s,${data.terraform_remote_state.ldap.outputs.ldap_base_users}"
    STORE_ALFRESCO_URL = "https://alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}/alfresco/service/"
    # ... Add any environment variables here that should be pulled from Terraform data sources.
    #     Other environment variables are managed by CircleCI. See https://github.com/ministryofjustice/ndelius-new-tech/blob/master/.circleci/config.yml
  })
  secrets = merge({ for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }, {
    APPLICATION_SECRET   = "/${var.environment_name}/${var.project_name}/newtech/web/application_secret"
    CUSTODY_API_USERNAME = "/${var.environment_name}/${var.project_name}/newtech/web/custody_api_username"
    CUSTODY_API_PASSWORD = "/${var.environment_name}/${var.project_name}/newtech/web/custody_api_password"
    GOOGLE_ANALYTICS_ID  = "/${var.environment_name}/${var.project_name}/monitoring/analytics/google_id"
    PARAMS_SECRET_KEY    = "/${var.environment_name}/${var.project_name}/newtech/web/params_secret_key"
    # ... Add any other secrets here that should be pulled from AWS Systems Manager Parameter Store
  })

  # Security/Networking
  lb_listener_arn   = data.terraform_remote_state.ndelius.outputs.lb_listener_arn # Attach to NDelius load balancer
  lb_path_patterns  = ["/newTech", "/newTech/*"]
  health_check_path = "/newTech/healthcheck"
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_new_tech_instances_id
  ]

  # Monitoring
  notification_arn            = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn
  load_balancer_arn           = data.terraform_remote_state.ndelius.outputs.alb["arn"]
  enable_telemetry            = true
  create_lb_alarms            = true
  enable_response_code_alarms = false # Temporarily disabled until 500 errors are resolved by developers
  log_error_pattern           = "error"

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

