locals {
  app_name        = "pwm"
  image_url       = "fjudith/pwm"
  image_version   = "latest"
  config_location = "/usr/share/pwm"
  pwm_config      = "${merge(var.default_pwm_config, var.pwm_config)}"
}
