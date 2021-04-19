module "ecs_service" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name = local.app_name
  container_definitions = [{
    image      = "${local.app_config["image_url"]}:${local.app_config["version"]}"
    entryPoint = ["java", "-Duser.timezone=Europe/London", "-Dui.config.redirectUri=/aptracker-api/errors", "-jar", "/app/app.jar"]
  }]
  environment = {
    SPRING_DATASOURCE_URL                   = data.terraform_remote_state.database.outputs.jdbc_failover_url
    SPRING_DATASOURCE_USERNAME              = "delius_app_schema"
    SPRING_DATASOURCE_TYPE                  = "oracle.jdbc.pool.OracleDataSource"
    SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT = "org.hibernate.dialect.Oracle10gDialect"
    SPRING_JPA_HIBERNATE_DDL-AUTO           = "none"
    SECURITY_OAUTH2_RESOURCE_ID             = "NDelius"
    SECURITY_OAUTH2_RESOURCE_TOKEN-INFO-URI = "http://usermanagement.ecs.cluster:8080/umt/oauth/check_token"
    LOGGING_LEVEL_UK_GOV_JUSTICE            = local.app_config["log_level"]
  }
  secrets = {
    SPRING_DATASOURCE_PASSWORD           = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_app_schema_password"
    SECURITY_OAUTH2_CLIENT_CLIENT-ID     = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/aptracker_user"
    SECURITY_OAUTH2_CLIENT_CLIENT-SECRET = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/aptracker_password"
  }

  # Security & Networking
  lb_listener_arn   = data.terraform_remote_state.ndelius.outputs.lb_listener_arn # Attach to NDelius load balancer
  lb_path_patterns  = ["/aptracker-api", "/aptracker-api/*"]
  health_check_path = "/aptracker-api/actuator/health"
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_aptracker_api_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id,
  ]

  # Monitoring
  enable_telemetry  = true
  create_lb_alarms  = true
  load_balancer_arn = data.terraform_remote_state.ndelius.outputs.alb["arn"]
  log_error_pattern = "ERROR"
  notification_arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

