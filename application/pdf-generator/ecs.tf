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

  # Auto-Scaling
  cpu              = local.app_config["cpu"]
  memory           = local.app_config["memory"]
  min_capacity     = local.app_config["min_capacity"]
  max_capacity     = local.app_config["max_capacity"]
  target_cpu_usage = local.app_config["target_cpu"]
}

