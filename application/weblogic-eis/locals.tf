locals {
  app_name    = "weblogic-eis"
  app_config  = merge(var.default_delius_app_config, var.delius_app_config)
  secrets     = { for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }
  environment = { for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }
}

