locals {
  app_name   = "new-tech"
  app_config = merge(var.default_new_tech_config, var.new_tech_config)
  secrets = merge({ for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }, {
    APPLICATION_SECRET   = "/${var.environment_name}/${var.project_name}/newtech/web/application_secret"
    CUSTODY_API_USERNAME = "/${var.environment_name}/${var.project_name}/newtech/web/custody_api_username"
    CUSTODY_API_PASSWORD = "/${var.environment_name}/${var.project_name}/newtech/web/custody_api_password"
    GOOGLE_ANALYTICS_ID  = "/${var.environment_name}/${var.project_name}/monitoring/analytics/google_id"
  })
  environment = merge({ for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }, {
    LDAP_STRING_FORMAT = "cn=%s,${data.terraform_remote_state.ldap.outputs.ldap_base_users}" # TODO check if this is still needed
    STORE_ALFRESCO_URL = "https://alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}/alfresco/service/"
    # ... Add any other environment variables here that should be pulled from Terraform data sources
  })
}

