locals {
  app_name   = "password-reset"
  short_name = "pwm"
  app_config = merge(var.default_pwm_config, var.pwm_config)
  migrated_envs = ["delius-mis-dev"]

  migration_dns_name = {
    "delius-mis-dev" = "delius-core-dev-ancilliary-alb-1061312108.eu-west-2.elb.amazonaws.com"
#     "delius-test" = "ldap-test-nlb-a54f13004f5f847d.elb.eu-west-2.amazonaws.com"
  }
}

