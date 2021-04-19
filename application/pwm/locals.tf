locals {
  app_name   = "password-reset"
  short_name = "pwm"
  app_config = merge(var.default_pwm_config, var.pwm_config)
}

