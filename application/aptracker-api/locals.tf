locals {
  app_name             = "delius-aptracker-api"
  image_url            = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-aptracker-api"
  aptracker_api_config = merge(var.default_aptracker_api_config, var.aptracker_api_config)
}

