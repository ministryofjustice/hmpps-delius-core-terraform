module "ecs" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                   = var.app_name
  ignore_task_definition_changes = true # Deployment is managed by Ansible
  container_definitions = [{
    image = var.app_config["image_url"]
    user  = "root"
  }]
  additional_log_files = {
    access_log = "/u01/domains/NDelius/servers/AdminServer/logs/access.log"
  }
  environment = merge({
    AWS_REGION          = var.region
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
    COOKIE_SECURE       = true

    ELASTICSEARCH_URL     = "/newTech"
    DELIUS_API_URL        = "http://delius-api.ecs.cluster:8080"
    GDPR_URL              = "/gdpr/ui/homepage"
    MERGE_URL             = "/merge/ui/"
    MERGE_API_URL         = "http://merge-api.ecs.cluster:8080/merge/api/"
    MERGE_OAUTH_URL       = "http://usermanagement.ecs.cluster:8080/umt/"
    NDELIUS_CLIENT_ID     = "NDelius"
    PDFCREATION_TEMPLATES = "shortFormatPreSentenceReport|paroleParom1Report|oralReport"
    PDFCREATION_URL       = "/newTech"
    USERMANAGEMENT_URL    = "/umt/"
  }, local.environment)
  secrets = merge({
    ADMIN_PASSWORD        = "/${var.environment_name}/${var.project_name}/weblogic/ndelius-domain/weblogic_admin_password"
    JDBC_PASSWORD         = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_pool_password"
    LDAP_CREDENTIAL       = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
    USERMANAGEMENT_SECRET = "/${var.environment_name}/${var.project_name}/umt/umt/delius_secret"
    MERGE_SECRET          = "/${var.environment_name}/${var.project_name}/weblogic/ndelius-domain/umt_client_secret"
    PDFCREATION_SECRET    = "/${var.environment_name}/${var.project_name}/newtech/web/params_secret_key"
    ANALYTICS_TAG         = "/${var.environment_name}/${var.project_name}/monitoring/analytics/google_id"
    TOPIC_ARN             = "/${var.environment_name}/${var.project_name}/moj-cloud-platform/hmpps-domain-events/topic-arn"
    AWS_ACCESS_KEY_ID     = "/${var.environment_name}/${var.project_name}/moj-cloud-platform/hmpps-domain-events/aws-access-key-id"
    AWS_SECRET_ACCESS_KEY = "/${var.environment_name}/${var.project_name}/moj-cloud-platform/hmpps-domain-events/aws-secret-access-key"
  }, local.secrets)

  # Security & Networking
  lb_stickiness_enabled             = true
  lb_algorithm_type                 = "least_outstanding_requests" # to send new sessions to fresh hosts after a scale-out
  health_check_path                 = var.health_check_path
  health_check_matcher              = var.health_check_matcher
  health_check_timeout              = 15 # Should be greater than WebLogic's "Connection Reserve Timeout", which defaults to 10 seconds
  health_check_unhealthy_threshold  = 10 # Increased unhealthy threshold to allow longer for recovery, due to instances being stateful
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  security_groups = concat(var.security_groups_instances, [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id
  ])

  # Monitoring
  enable_jmx_metrics          = true
  jmx_exporter_config         = "/home/oracle/.jmx-exporter/jmx-exporter.yml"
  enable_telemetry            = true
  create_lb_alarms            = true
  load_balancer_arn           = aws_lb.alb.arn
  enable_response_code_alarms = false # 500 responses are sometimes returned for normal operations e.g. OASys offender not found
  enable_response_time_alarms = var.enable_response_time_alarms
  log_error_pattern           = "FATAL"
  notification_arn            = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Auto-Scaling
  disable_scale_in   = true  # Sessions are stored in-memory - see lambda.tf for nightly scheduled scale-in function
  enable_cpu_scaling = false # Application is memory-bound - see autoscaling.tf for scaling rule based on JVM heap usage
  cpu                = var.app_config["cpu"]
  memory             = var.app_config["memory"]
  min_capacity       = var.app_config["min_capacity"]
  max_capacity       = var.app_config["max_capacity"]
}

