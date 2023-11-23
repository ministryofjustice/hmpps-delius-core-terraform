locals {
  # Override default values
  ldap_config = merge(var.default_ldap_config, var.ldap_config)

  migrated_envs = ["delius-mis-dev"]
}

