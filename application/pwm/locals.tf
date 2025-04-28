locals {
  app_name      = "password-reset"
  short_name    = "pwm"
  app_config    = merge(var.default_pwm_config, var.pwm_config)
  migrated_envs = ["delius-mis-dev", "delius-test", "delius-stage", "delius-pre-prod", "delius-prod"]

  migration_url = {
    "delius-mis-dev"  = "pwm.dev.delius-core.hmpps-development.modernisation-platform.service.justice.gov.uk"
    "delius-test"     = "pwm.test.delius-core.hmpps-test.modernisation-platform.service.justice.gov.uk"
    "delius-stage"    = "pwm.stage.delius-core.hmpps-preproduction.modernisation-platform.service.justice.gov.uk"
    "delius-pre-prod" = "pwm.preprod.delius-core.hmpps-preproduction.modernisation-platform.service.justice.gov.uk"
    "delius-prod"     = "pwm.prod.delius-core.hmpps-production.modernisation-platform.service.justice.gov.uk"
  }
}
