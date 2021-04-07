locals {
  app_name   = "merge"
  api_name   = "merge-api"
  ui_name    = "merge-ui"
  db_name    = "mergedb"
  app_config = merge(var.default_merge_config, var.merge_config)
}

