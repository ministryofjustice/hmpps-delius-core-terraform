locals {
  # Override default values
  ldap_config = merge(var.default_ldap_config, var.ldap_config)

  migrated_envs = ["delius-mis-dev", "delius-test"]

  migration_nlb_dns_name = {
    "delius-mis-dev" = "ldap.dev.delius-core.hmpps-development.modernisation-platform.service.justice.gov.uk"
    "delius-test" = "ldap.test.delius-core.hmpps-test.modernisation-platform.service.justice.gov.uk"
  }
}

