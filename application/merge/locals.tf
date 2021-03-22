locals {
  app_name     = "merge"
  api_name     = "merge-api"
  ui_name      = "merge-ui"
  app_config   = merge(var.default_merge_config, var.merge_config)
  ansible_vars = merge(var.default_ansible_vars, var.ansible_vars)
}

