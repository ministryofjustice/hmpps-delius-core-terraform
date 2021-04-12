locals {
  app_name   = "delius-aptracker-api"
  app_config = merge(var.default_aptracker_api_config, var.aptracker_api_config)
}

