locals {
  secrets     = { for key, value in var.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }
  environment = { for key, value in var.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }
}

