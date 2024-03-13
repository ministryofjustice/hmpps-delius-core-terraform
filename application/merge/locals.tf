locals {
  app_name    = "merge"
  api_name    = "merge-api"
  ui_name     = "merge-ui"
  db_name     = "mergedb"
  common_name = "${var.environment_identifier}-${local.app_name}"
  app_config  = merge(var.default_merge_config, var.merge_config)
  secrets     = { for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }
  environment = { for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }
}

