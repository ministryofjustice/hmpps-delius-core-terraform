locals {
  app_name     = "delius-gdpr"
  api_name     = "delius-gdpr-api"
  ui_name      = "delius-gdpr-ui"
  gdpr_config  = merge(var.default_gdpr_config, var.gdpr_config)
  ansible_vars = merge(var.default_ansible_vars, var.ansible_vars)
}

