module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                   = local.app_name
  ignore_task_definition_changes = true # Deployment is managed by Circle CI
  container_definitions = [{
    image = local.app_config["image_url"]
    healthCheck = {
      command = ["CMD-SHELL", "health=$(curl -sf http://localhost:8080/healthcheck || exit 1) && echo $health | jq -e '.status == \"OK\"'"]
    }
  }]
  environment = { for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }

  # Security & Networking
  target_group_count = 0 # Internal only - no load balancer required
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_pdf_generator_instances_id
  ]

  # Monitoring
  enable_telemetry  = true
  log_error_pattern = "ERROR"
  notification_arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

