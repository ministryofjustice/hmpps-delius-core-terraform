locals {
  app_name          = "usermanagement"
  app_config        = merge(var.default_umt_config, var.umt_config)
  ldap_config       = merge(var.default_ldap_config, var.ldap_config)
  delius_app_config = merge(var.default_delius_app_config, var.delius_app_config)
}

