locals {
  app_name   = "delius-api"
  app_config = merge(var.default_delius_api_config, var.delius_api_config)
}

