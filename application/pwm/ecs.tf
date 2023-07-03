module "service" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name          = local.app_name
  container_definitions = [{ image = "${local.app_config["image_url"]}:${local.app_config["version"]}" }]
  environment = {
    CONFIG_XML_BASE64 = base64encode(templatefile("${path.module}/templates/PwmConfiguration.xml.tpl", {
      region = var.region
      # ldap_url           = "${data.terraform_remote_state.ldap.outputs.ldap_protocol}://${data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.outputs.ldap_port}"
      ldap_url = "ldap://${data.aws_ssm_parameter.mp_ldap_host.value}:389"
      # ldap_user = data.terraform_remote_state.ldap.outputs.ldap_bind_user
      ldap_user = data.aws_ssm_parameter.mp_ldap_principal.value
      # user_base          = data.terraform_remote_state.ldap.outputs.ldap_base_users
      user_base          = data.aws_ssm_parameter.mp_ldap_principal.value
      site_url           = "https://${aws_route53_record.public_dns.fqdn}"
      email_smtp_address = "smtp.${data.terraform_remote_state.vpc.outputs.private_zone_name}"
      email_from_address = "no-reply@${data.terraform_remote_state.vpc.outputs.public_zone_name}"
    }))
  }
  secrets = {
    SECURITY_KEY    = "/${var.environment_name}/${var.project_name}/pwm/pwm/security_key"
    CONFIG_PASSWORD = "/${var.environment_name}/${var.project_name}/pwm/pwm/config_password"
    # LDAP_PASSWORD   = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
    LDAP_PASSWORD = data.aws_ssm_parameter.mp_ldap_password.name
  }

  # Security & Networking
  lb_stickiness_enabled             = true
  health_check_matcher              = "200-399"
  health_check_grace_period_seconds = 60 # Reduced grace period, to speed up container replacement as PWM intermittently fails on initial startup due to https://github.com/pwm-project/pwm/issues/557
  security_groups = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_smtp_ses,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_pwm_instances_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
  ]

  # Monitoring
  notification_arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn
  enable_telemetry  = true
  create_lb_alarms  = true
  load_balancer_arn = aws_lb.alb.arn
  log_error_pattern = "FATAL"

  # Auto-Scaling
  cpu              = lookup(local.app_config, "cpu", var.common_ecs_scaling_config["cpu"])
  memory           = lookup(local.app_config, "memory", var.common_ecs_scaling_config["memory"])
  min_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["min_capacity"])
  max_capacity     = lookup(local.app_config, "min_capacity", var.common_ecs_scaling_config["max_capacity"])
  target_cpu_usage = lookup(local.app_config, "target_cpu", var.common_ecs_scaling_config["target_cpu"])
}

