locals {
  # Override default values
  ldap_config = merge(var.default_ldap_config, var.ldap_config)

  migrated_envs = ["delius-mis-dev", "delius-test", "delius-stage", "delius-pre-prod", "delius-prod"]

  migration_nlb_dns_name = {
    "delius-mis-dev"  = "ldap.dev.delius-core.hmpps-development.modernisation-platform.service.justice.gov.uk"
    "delius-test"     = "ldap.test.delius-core.hmpps-test.modernisation-platform.service.justice.gov.uk"
    "delius-stage"    = "ldap.stage.delius-core.hmpps-preproduction.modernisation-platform.service.justice.gov.uk"
    "delius-pre-prod" = "ldap.preprod.delius-core.hmpps-preproduction.modernisation-platform.service.justice.gov.uk"
    "delius-prod"     = "ldap.prod.delius-core.hmpps-production.modernisation-platform.service.justice.gov.uk"
    "delius-training" = "ldap.training.delius-core-training.hmpps-production.modernisation-platform.service.justice.gov.uk"
  }
}

