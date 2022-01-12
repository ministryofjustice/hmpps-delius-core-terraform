module "api" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name = local.api_name
  container_definitions = [{
    image      = "${local.app_config["api_image_url"]}:${local.app_config["api_version"]}"
    entryPoint = ["java", "-Duser.timezone=Europe/London", "-jar", "/app.jar"]
  }]
  environment = {
    SERVER_SERVLET_CONTEXT_PATH                                          = "/merge/api/"
    SPRING_DATASOURCE_JDBC-URL                                           = "jdbc:postgresql://${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.name}"
    SPRING_DATASOURCE_USERNAME                                           = aws_db_instance.primary.username
    SPRING_DATASOURCE_DRIVER-CLASS-NAME                                  = "org.postgresql.Driver"
    SPRING_SECOND-DATASOURCE_JDBC-URL                                    = data.terraform_remote_state.database.outputs.jdbc_failover_url
    SPRING_SECOND-DATASOURCE_USERNAME                                    = "mms_pool"
    SPRING_SECOND-DATASOURCE_TYPE                                        = "oracle.jdbc.pool.OracleDataSource"
    SCHEDULE_MERGEUNMERGE                                                = local.app_config["schedule"]
    SPRING_JPA_HIBERNATE_DDL-AUTO                                        = "update"
    SPRING_BATCH_JOB_ENABLED                                             = "false"
    SPRING_BATCH_INITIALIZE-SCHEMA                                       = "always"
    ALFRESCO_DMS-PROTOCOL                                                = "https"
    ALFRESCO_DMS-HOST                                                    = "alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
    SECURITY_OAUTH2_RESOURCE_ID                                          = "NDelius"
    SPRING_SECURITY_OAUTH2_RESOURCESERVER_OPAQUE-TOKEN_CLIENT-ID         = "Merge-API"
    SPRING_SECURITY_OAUTH2_RESOURCESERVER_OPAQUE-TOKEN_INTROSPECTION-URI = "http://usermanagement.ecs.cluster:8080/umt/oauth/check_token"
    LOGGING_LEVEL_UK_GOV_JUSTICE                                         = local.app_config["log_level"]
    SPRING_FLYWAY_ENABLED                                                = "true"
    SPRING_FLYWAY_LOCATIONS                                              = "classpath:/db"
  }
  secrets = {
    SPRING_SECOND-DATASOURCE_PASSWORD                                = "/${var.environment_name}/${var.project_name}/delius-database/db/mms_pool_password"
    SPRING_DATASOURCE_PASSWORD                                       = "/${var.environment_name}/${var.project_name}/merge/db/admin_password"
    SPRING_SECURITY_OAUTH2_RESOURCESERVER_OPAQUE-TOKEN_CLIENT-SECRET = "/${var.environment_name}/${var.project_name}/merge/api/client_secret"
  }

  # Security & Networking
  lb_listener_arn   = data.terraform_remote_state.ndelius.outputs.lb_listener_arn # Attach to NDelius load balancer
  lb_path_patterns  = ["/merge/api", "/merge/api/*"]
  health_check_path = "/merge/api/actuator/health"
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_merge_api_id,
  ]

  # Monitoring
  enable_telemetry  = true
  create_lb_alarms  = true
  load_balancer_arn = data.terraform_remote_state.ndelius.outputs.alb["arn"]
  log_error_pattern = "ERROR"
  notification_arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Scaling
  cpu          = lookup(local.app_config, "api_cpu", var.common_ecs_scaling_config["cpu"])
  memory       = lookup(local.app_config, "api_memory", var.common_ecs_scaling_config["memory"])
  min_capacity = lookup(local.app_config, "api_min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity = lookup(local.app_config, "api_max_capacity", var.common_ecs_scaling_config["max_capacity"])
}

