locals {
  app_name   = "new-tech"
  app_config = merge(var.default_new_tech_config, var.new_tech_config)
}

