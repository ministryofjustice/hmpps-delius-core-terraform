locals {
  # Override default values
  ldap_config = merge(var.default_ldap_config, var.ldap_config)

  migrated_envs = ["delius-mis-dev", "delius-test"]

  migration_nlb_dns_name = {
    "delius-mis-dev" = "ldap-dev-nlb-7667124ead573c5a.elb.eu-west-2.amazonaws.com"
    "delius-test" = "ldap-test-nlb-a54f13004f5f847d.elb.eu-west-2.amazonaws.com"
  }
}

