module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name          = local.app_name
  container_definitions = [{ image = "${local.app_config["image_url"]}:${local.app_config["version"]}" }]
  environment = {
    JAVA_OPTS                                  = "-XX:MaxMetaspaceSize=512M -XX:MaxDirectMemorySize=128M" /* Override non-heap allocations calculated by https://github.com/cloudfoundry/java-buildpack-memory-calculator
                                                                                                        * to prevent the following errors: "OutOfMemoryError: Metaspace" and "OutOfMemoryError: Direct buffer memory".
                                                                                                        */
    TZ                                         = "Europe/London"
    SERVER_USE-FORWARD-HEADERS                 = "true"
    SERVER_FORWARD-HEADERS-STRATEGY            = "native"
    SPRING_DATASOURCE_URL                      = data.terraform_remote_state.database.outputs.jdbc_failover_url
    SPRING_DATASOURCE_USERNAME                 = "delius_app_schema"
    SPRING_DATASOURCE_TYPE                     = "com.zaxxer.hikari.HikariDataSource"
    SPRING_DATASOURCE_HIKARI_MAXIMUM-POOL-SIZE = "50"
    SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT    = "org.hibernate.dialect.Oracle12cDialect"
    SPRING_JPA_HIBERNATE_DDL-AUTO              = "none"
    SPRING_LDAP_URLS                           = "${data.terraform_remote_state.ldap.outputs.ldap_protocol}://${data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.outputs.ldap_port}"
    SPRING_LDAP_EXPORT_USERNAME                = "cn=root,${local.ldap_config["base_root"]}"
    SPRING_LDAP_USERNAME                       = "cn=root,${local.ldap_config["base_root"]}"
    SPRING_LDAP_BASE                           = local.ldap_config["base_root"]
    SPRING_LDAP_USEORACLEATTRIBUTES            = "false"
    SPRING_REDIS_HOST                          = aws_route53_record.token_store_private_dns.fqdn
    SPRING_REDIS_PORT                          = aws_elasticache_replication_group.token_store_replication_group.port
    SPRING_REDIS_CLUSTER_NODES                 = "${aws_route53_record.token_store_private_dns.fqdn}:${aws_elasticache_replication_group.token_store_replication_group.port}"
    REDIS_CONFIGURE_NO-OP                      = "true"
    DELIUS_PASSWORD-RESET_URL                  = data.terraform_remote_state.pwm.outputs.url
    DELIUS_LDAP_BASE_USERS                     = replace(local.ldap_config["base_users"], ",${local.ldap_config["base_root"]}", "")
    DELIUS_LDAP_BASE_CLIENTS                   = replace(local.ldap_config["base_service_users"], ",${local.ldap_config["base_root"]}", "")
    DELIUS_LDAP_BASE_ROLES                     = replace(local.ldap_config["base_roles"], ",${local.ldap_config["base_root"]}", "")
    DELIUS_LDAP_BASE_ROLE-GROUPS               = replace(local.ldap_config["base_role_groups"], ",${local.ldap_config["base_root"]}", "")
    DELIUS_LDAP_BASE_GROUPS                    = replace(local.ldap_config["base_groups"], ",${local.ldap_config["base_root"]}", "")
    LOGGING_LEVEL_UK_CO_BCONLINE_NDELIUS       = local.delius_app_config["env_LOG_LEVEL_NDELIUS"]
  }
  secrets = {
    JWT_SECRET                 = "/${var.environment_name}/${var.project_name}/umt/umt/jwt_secret"
    DELIUS_SECRET              = "/${var.environment_name}/${var.project_name}/umt/umt/delius_secret"
    SPRING_DATASOURCE_PASSWORD = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_app_schema_password"
    SPRING_LDAP_PASSWORD       = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
  }

  # Security/Networking
  target_group_count = 0 # Attach to NDelius load balancer
  lb_listener_arns = concat(
    [data.terraform_remote_state.ndelius.outputs.lb_listener_arn],
    (var.dual_run_with_sr28 ? [data.terraform_remote_state.ndelius_sr28.0.outputs.lb_listener_arn] : []),
  )
  lb_path_patterns  = ["/umt", "/umt/*"]
  health_check_path = "/umt/actuator/health"
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_instances_id
  ]

  # Monitoring
  enable_telemetry            = true
  enable_jmx_metrics          = true
  create_lb_alarms            = true
  enable_response_time_alarms = false # Response times can exceed 1s during normal use (e.g. Exports and Role Searches)
  load_balancer_arn           = data.terraform_remote_state.ndelius.outputs.alb["arn"]
  log_error_pattern           = "ERROR"
  notification_arn            = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

