module "ui" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name = local.ui_name
  service_port = 80
  container_definitions = [{
    image = "${local.app_config["ui_image_url"]}:${local.app_config["ui_version"]}"
    # Overriding the command variable allows us to inject config files into the container:
    command = ["sh", "-c", <<-EOT
      echo '${replace(file("nginx/default.conf"), "\n", "")}' > /etc/nginx/conf.d/default.conf && \
      echo "${replace(file("angular/config.js"), "\n", "")}" > /usr/share/nginx/html/assets/config/config.js && \
      exec nginx -g 'daemon off;'
      EOT
    ]
  }]

  # Security & Networking
  lb_listener_arn   = data.terraform_remote_state.ndelius.outputs.lb_listener_arn # Attach to NDelius load balancer
  lb_path_patterns  = ["/gdpr/ui", "/gdpr/ui/*"]
  health_check_path = "/gdpr/ui/homepage"
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_auth_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_gdpr_ui_id,
  ]

  # Auto-Scaling
  cpu              = lookup(local.app_config, "ui_cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "ui_memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "ui_min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "ui_min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "ui_target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

