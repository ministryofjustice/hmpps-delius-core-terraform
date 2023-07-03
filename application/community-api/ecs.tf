module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                   = local.app_name
  container_definitions          = [{ image = local.app_config["image_url"] }]
  ignore_task_definition_changes = true # Deployment is managed by Circle CI
  health_check_path              = "/health/ping"
  environment = merge(local.environment, {
    SPRING_PROFILES_ACTIVE     = "oracle"
    SPRING_DATASOURCE_USERNAME = "delius_pool"
    SPRING_DATASOURCE_URL      = data.terraform_remote_state.database.outputs.jdbc_failover_url

    # DELIUS_LDAP_USERS_BASE     = data.terraform_remote_state.ldap.outputs.ldap_base_users
    DELIUS_LDAP_USERS_BASE = data.aws_ssm_parameter.mp_ldap_user_base.value

    # SPRING_LDAP_USERNAME       = data.terraform_remote_state.ldap.outputs.ldap_bind_user
    SPRING_LDAP_USERNAME = data.aws_ssm_parameter.mp_ldap_principal.value

    # SPRING_LDAP_URLS           = "${data.terraform_remote_state.ldap.outputs.ldap_protocol}://${data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.outputs.ldap_port}"
    SPRING_LDAP_URLS = "ldap://${data.aws_ssm_parameter.mp_ldap_host.value}:389"

    ALFRESCO_BASEURL   = "https://alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}/alfresco/s/noms-spg"
    DELIUS_BASEURL     = "http://${data.terraform_remote_state.interface.outputs.service_discovery_url}:7001/api"
    SENTRY_ENVIRONMENT = var.environment_name
    # ... Add any environment variables here that should be pulled from Terraform data sources.
    #     Other environment variables are managed by CircleCI. See https://github.com/ministryofjustice/community-api/blob/main/.circleci/config.yml
  })
  secrets = merge(local.secrets, {
    APPINSIGHTS_INSTRUMENTATIONKEY = "/${var.environment_name}/${var.project_name}/newtech/offenderapi/appinsights_key"
    SPRING_DATASOURCE_PASSWORD     = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_pool_password"
    # SPRING_LDAP_PASSWORD           = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
    SPRING_LDAP_PASSWORD = data.aws_ssm_parameter.mp_ldap_password.name
    DELIUS_USERNAME      = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/casenotes_user"
    DELIUS_PASSWORD      = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/casenotes_password"
    SENTRY_DSN           = "/${var.environment_name}/${var.project_name}/probation-integration/community-api/sentry-dsn"
  })

  # Security & Networking
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_community_api_instances_id
  ]
  target_group_count = 3 # Currently there are 3 load balancers - default (community-api), public (community-api-public), and legacy/secure (community-api-secure)

  # Monitoring
  notification_arn            = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn
  load_balancer_arn           = aws_lb.alb.arn
  create_lb_alarms            = true
  enable_response_code_alarms = false # Temporarily disabled until 500 errors are resolved by developers
  log_error_pattern           = "ERROR"

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

