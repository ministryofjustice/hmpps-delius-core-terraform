module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name          = var.app_name
  container_definitions = [{ image = "${var.app_config["image_url"]}:${var.app_config["version"]}" }]
  environment = merge({
    TZ                  = "Europe/London"
    JDBC_URL            = data.terraform_remote_state.database.outputs.jdbc_failover_url
    JDBC_USERNAME       = "delius_pool"
    LDAP_HOST           = data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb
    LDAP_PRINCIPAL      = data.terraform_remote_state.ldap.outputs.ldap_bind_user
    USER_CONTEXT        = data.terraform_remote_state.ldap.outputs.ldap_base_users
    EIS_USER_CONTEXT    = "cn=EISUsers,${data.terraform_remote_state.ldap.outputs.ldap_base_users}"
    DMS_PROTOCOL        = "https"
    DMS_HOST            = "alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
    DMS_PORT            = 443
    DMS_OFFICE_URI_HOST = "alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}"
    DMS_OFFICE_URI_PORT = 443
    PASSWORD_RESET_URL  = data.terraform_remote_state.pwm.outputs.url

    APTRACKER_ERRORS_URL  = "/aptracker-api/errors"
    ELASTICSEARCH_URL     = "/newTech"
    GDPR_URL              = "/gdpr/ui/homepage"
    MERGE_URL             = "/merge/ui/"
    MERGE_API_URL         = "/merge/api/"
    MERGE_OAUTH_URL       = "/umt/"
    NDELIUS_CLIENT_ID     = "ndelius.client"
    PDFCREATION_TEMPLATES = "shortFormatPreSentenceReport|paroleParom1Report|oralReport"
    PDFCREATION_URL       = "/newTech"
    USERMANAGEMENT_URL    = "/umt/"
  }, local.environment)
  secrets = merge({
    ADMIN_PASSWORD        = "/${var.environment_name}/${var.project_name}/weblogic/ndelius-domain/weblogic_admin_password"
    JDBC_PASSWORD         = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_pool_password"
    LDAP_CREDENTIAL       = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
    USERMANAGEMENT_SECRET = "/${var.environment_name}/${var.project_name}/umt/umt/delius_secret"
    MERGE_SECRET          = "/${var.environment_name}/${var.project_name}/merge/api/client_secret"
    PDFCREATION_SECRET    = "/${var.environment_name}/${var.project_name}/newtech/web/params_secret_key"
    ANALYTICS_TAG         = "/${var.environment_name}/${var.project_name}/monitoring/analytics/google_id"
  }, local.secrets)

  # Security & Networking
  lb_stickiness_enabled            = true
  health_check_path                = "/NDelius-war/delius/JSP/homepage.jsp"
  health_check_matcher             = "200-399"
  health_check_unhealthy_threshold = 10 # increased unhealthy threshold to allow longer for recovery, due to instances being stateful
  security_groups = concat(var.security_groups_instances, [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id
  ])

  # Monitoring
  enable_telemetry  = true
  create_lb_alarms  = true
  load_balancer_arn = aws_lb.alb.arn
  notification_arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn
  log_error_pattern = "ERROR"

  # Auto-Scaling
  disable_scale_in = true
  cpu              = var.app_config["cpu"]
  memory           = var.app_config["memory"]
  min_capacity     = var.app_config["min_capacity"]
  max_capacity     = var.app_config["max_capacity"]
  target_cpu_usage = var.app_config["target_cpu"]
}
