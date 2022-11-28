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
  health_check_path              = "/health"
  environment = merge(var.delius_api_environment, {
    SPRING_DATASOURCE_URL         = data.terraform_remote_state.database.outputs.jdbc_failover_url
    ALFRESCO_BASEURL              = "https://alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
    SPRING_ELASTICSEARCH_URIS     = "https://${data.terraform_remote_state.elasticsearch.outputs.contact_search["endpoint"]}:443"
    SPRING_ELASTICSEARCH_USERNAME = data.terraform_remote_state.elasticsearch.outputs.contact_search["username"]
    NEW-TECH-SERVICE_BASEURL      = "${data.terraform_remote_state.ndelius.outputs.public_url}/newTech"
    SENTRY_ENVIRONMENT            = var.environment_name
  })
  secrets = merge(var.delius_api_secrets, {
    SPRING_ELASTICSEARCH_PASSWORD = data.terraform_remote_state.elasticsearch.outputs.contact_search["password_key"]
    NEW-TECH-SERVICE_SECRET       = "/${var.environment_name}/${var.project_name}/newtech/web/params_secret_key"
    SENTRY_DSN                    = "/${var.environment_name}/${var.project_name}/delius-api/sentry/dsn"
  })

  # Security & Networking
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_api_instances_id
  ]
  target_group_count = 2 # There are 2 load balancers - default (delius-api), and public (delius-api-public)

  # Monitoring
  notification_arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn
  create_lb_alarms  = true
  load_balancer_arn = aws_lb.alb.arn
  log_error_pattern = "ERROR"

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = length(keys(var.delius_api_environment)) == 0 ? 0 : lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = length(keys(var.delius_api_environment)) == 0 ? 0 : lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

