locals {
  app_name    = "delius-gdpr"
  api_name    = "delius-gdpr-api"
  ui_name     = "delius-gdpr-ui"
  common_name = "${var.environment_identifier}-${local.app_name}"
  app_config  = merge(var.default_gdpr_config, var.gdpr_config)
  secrets     = { for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }
  environment = { for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }
}

