locals {
  app_name   = "password-reset"
  short_name = "pwm"
  app_config = merge(var.default_pwm_config, var.pwm_config)
  migrated_envs = ["delius-mis-dev"]

  migration_url = {
    "delius-mis-dev" = "pwm.dev.delius-core.hmpps-development.modernisation-platform.service.justice.gov.uk"
#     "delius-test" = "ldap-test-nlb-a54f13004f5f847d.elb.eu-west-2.amazonaws.com"
  }
}

