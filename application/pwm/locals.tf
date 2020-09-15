locals {
  app_name   = "password-reset"
  short_name = "pwm"
  image_name = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/pwm"
  pwm_config = merge(var.default_pwm_config, var.pwm_config)
  ssm_prefix = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}"
}

