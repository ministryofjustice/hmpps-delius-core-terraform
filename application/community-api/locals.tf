locals {
  app_name   = "community-api"
  short_name = "comapi"
  app_config = merge(var.default_community_api_config, var.community_api_config)
  secrets = merge({ for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }, {
    SPRING_DATASOURCE_PASSWORD     = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_pool_password"
    SPRING_LDAP_PASSWORD           = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password"
    APPINSIGHTS_INSTRUMENTATIONKEY = "/${var.environment_name}/${var.project_name}/newtech/offenderapi/appinsights_key"
    DELIUS_USERNAME                = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/casenotes_user"
    DELIUS_PASSWORD                = "/${var.environment_name}/${var.project_name}/apacheds/apacheds/casenotes_password"
    # ... Add any other secrets here
  })
  environment = merge({ for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }, {
    SPRING_DATASOURCE_URL  = data.terraform_remote_state.database.outputs.jdbc_failover_url
    SPRING_LDAP_URLS       = "${data.terraform_remote_state.ldap.outputs.ldap_protocol}://${data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb}:${data.terraform_remote_state.ldap.outputs.ldap_port}"
    SPRING_LDAP_USERNAME   = data.terraform_remote_state.ldap.outputs.ldap_bind_user
    DELIUS_LDAP_USERS_BASE = data.terraform_remote_state.ldap.outputs.ldap_base_users
    ALFRESCO_BASEURL       = "https://alfresco.${data.terraform_remote_state.vpc.outputs.public_zone_name}/alfresco/s/noms-spg"
    DELIUS_BASEURL         = "https://${data.terraform_remote_state.interface.outputs.private_fqdn_interface_wls_external}/api"
    # ... Add any other environment variables here that should be pulled from Terraform data sources
  })
  certificate_arn = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.legacy_cert.arn
  route53_zone_id = var.delius_core_public_zone == "strategic" ? data.terraform_remote_state.vpc.outputs.strategic_public_zone_id : data.terraform_remote_state.vpc.outputs.public_zone_id
  subnets = {
    private = [
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
    ]
    public = [
      data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
    ]
  }
}

