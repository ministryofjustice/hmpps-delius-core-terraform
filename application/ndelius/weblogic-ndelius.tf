# Weblogic tier ndelius

locals {
  # Override default values
  ansible_vars = merge(var.default_ansible_vars, var.ansible_vars)
}

module "ndelius" {
  # source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//weblogic-admin-only"
  source               = "../../modules/weblogic-admin-only"
  tier_name            = "ndelius"
  ami_id               = data.aws_ami.centos_wls.id
  instance_type        = var.instance_type_weblogic
  instance_count       = var.instance_count_weblogic_ndelius
  key_name             = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  iam_instance_profile = data.terraform_remote_state.key_profile.outputs.instance_profile_ec2_id

  instance_security_groups = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_ndelius_instances_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
  ]
  lb_security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_weblogic_ndelius_lb_id,
  ]

  public_subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
  ]

  private_subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]

  tags                         = var.tags
  environment_name             = data.terraform_remote_state.vpc.outputs.environment_name
  bastion_inventory            = data.terraform_remote_state.vpc.outputs.bastion_inventory
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier
  short_environment_name       = var.short_environment_name
  region                       = var.region
  vpc_id                       = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_account_id               = data.terraform_remote_state.vpc.outputs.vpc_account_id
  public_zone_id               = data.terraform_remote_state.vpc.outputs.public_zone_id
  private_zone_id              = data.terraform_remote_state.vpc.outputs.private_zone_id
  private_domain               = data.terraform_remote_state.vpc.outputs.private_zone_name

  # NOTE:
  # This is only in place to support transition from the old public zone (dsd.io) to the strategic public zone (gov.uk).
  # It allows us to configure which zone to use for public-facing services (eg. NDelius, PWM) on a per-environment
  # basis. Currently only Prod and Pre-Prod should use the old public zone, once they are transitioned over we should
  # remove this. Additionally, there are a few services that have DNS records in the public zone that should be moved
  # over into the private zone before we complete the transition eg. delius-db-1, management.
  # (see dns.tf)
  certificate_arn = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.cert.arn

  weblogic_health_check_path = "NDelius-war/delius/JSP/healthcheck.jsp"
  weblogic_port              = var.weblogic_domain_ports["weblogic_port"]

  app_bootstrap_src     = "https://github.com/ministryofjustice/hmpps-delius-core-bootstrap"
  app_bootstrap_version = "1.1.2"
  app_bootstrap_roles   = ["delius-core"]

  ansible_vars = {
    cldwatch_log_group = "${var.environment_identifier}/weblogic-ndelius"
    # Artefact locations
    s3_dependencies_bucket = substr(var.dependencies_bucket_arn, 13, -1)
    # Server/WebLogic config
    domain_name             = local.ansible_vars["domain_name"]
    server_name             = local.ansible_vars["server_name"]
    jvm_mem_args            = local.ansible_vars["jvm_mem_args"]
    server_params           = local.ansible_vars["jvm_mem_args"]
    weblogic_admin_username = local.ansible_vars["weblogic_admin_username"]
    server_listen_address   = local.ansible_vars["server_listen_address"]
    server_listen_port      = var.weblogic_domain_ports["weblogic_port"]
    # Database
    setup_datasources      = local.ansible_vars["setup_datasources"]
    primary_db_host        = data.terraform_remote_state.database_failover.outputs.public_fqdn_delius_db_1
    database_url           = data.terraform_remote_state.database_failover.outputs.jdbc_failover_url
    database_min_pool_size = local.ansible_vars["database_min_pool_size"]
    database_max_pool_size = local.ansible_vars["database_max_pool_size"]
    # Alfresco
    alfresco_host        = "${local.ansible_vars["alfresco_host"]}.${data.aws_route53_zone.public.name}"
    alfresco_port        = local.ansible_vars["alfresco_port"]
    alfresco_office_host = "${local.ansible_vars["alfresco_office_host"]}.${data.aws_route53_zone.public.name}"
    alfresco_office_port = local.ansible_vars["alfresco_office_port"]
    # LDAP
    ldap_host          = data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb
    ldap_readonly_host = data.terraform_remote_state.ldap.outputs.private_fqdn_ldap_elb
    ldap_port          = var.ldap_ports["ldap"]
    ldap_principal     = data.terraform_remote_state.ldap.outputs.ldap_bind_user
    ldap_base          = data.terraform_remote_state.ldap.outputs.ldap_base
    ldap_user_base     = data.terraform_remote_state.ldap.outputs.ldap_base_users
    ldap_group_base    = "cn=EISUsers,${data.terraform_remote_state.ldap.outputs.ldap_base_users}"
    # App config
    ndelius_display_name  = local.ansible_vars["ndelius_display_name"]
    ndelius_training_mode = local.ansible_vars["ndelius_training_mode"]
    ndelius_log_level     = local.ansible_vars["ndelius_log_level"]
    ndelius_analytics_tag = local.ansible_vars["ndelius_analytics_tag"]
    ldap_passfile         = local.ansible_vars["ldap_passfile"]
    # Newtech
    newtech_search_url             = local.ansible_vars["newtech_search_url"]
    newtech_pdfgenerator_url       = local.ansible_vars["newtech_pdfgenerator_url"]
    newtech_pdfgenerator_templates = local.ansible_vars["newtech_pdfgenerator_templates"]
    newtech_pdfgenerator_secret    = local.ansible_vars["newtech_pdfgenerator_secret"]
    # User Management Tool
    usermanagement_url = local.ansible_vars["usermanagement_url"]
    # NOMIS
    nomis_url           = local.ansible_vars["nomis_url"]
    nomis_client_id     = local.ansible_vars["nomis_client_id"]
    nomis_client_secret = local.ansible_vars["nomis_client_secret"]
    # Password Reset Tool
    password_reset_url = data.terraform_remote_state.pwm.outputs.url
    # Approved Premises Tracker API
    aptracker_api_errors_url = local.ansible_vars["aptracker_api_errors_url"]
  }
}

