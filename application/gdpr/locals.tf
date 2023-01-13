locals {
  app_name   = "delius-gdpr"
  api_name   = "delius-gdpr-api"
  ui_name    = "delius-gdpr-ui"
  app_config = merge(var.default_gdpr_config, var.gdpr_config)
  common_name = "${var.environment_identifier}-${local.app_name}"
}

