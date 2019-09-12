# Weblogic tier spg

locals {
  # Override default values
  ansible_vars = "${merge(var.default_ansible_vars, var.ansible_vars)}"
  ansible_vars_apacheds = "${merge(var.default_ansible_vars_apacheds, var.ansible_vars_apacheds)}"
}

module "spg" {
  # source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//weblogic-admin-only"
  source               = "../../modules/weblogic-admin-only"
  tier_name            = "spg"
  ami_id               = "${data.aws_ami.centos_wls.id}"
  instance_type        = "${var.instance_type_weblogic}"
  instance_count       = "${var.instance_count_weblogic_spg}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  instance_security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_spg_instances_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
    "${module.activemq-nfs.nfs_client_sg_id}"
  ]
  lb_security_groups = [
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_spg_lb_id}"
  ]

  public_subnets = "${list(
    data.terraform_remote_state.vpc.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.vpc_public-subnet-az3,
  )}"

  private_subnets = "${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"

  tags                         = "${var.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  project_name                 = "${var.project_name}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"
  short_environment_name       = "${var.short_environment_name}"
  environment_type             = "${var.environment_type}"
  region                       = "${var.region}"
  vpc_id                       = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_account_id               = "${data.terraform_remote_state.vpc.vpc_account_id}"
  kms_key_id                   = "${data.terraform_remote_state.key_profile.kms_arn_app}"
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id              = "${data.terraform_remote_state.vpc.private_zone_id}"
  private_domain               = "${data.terraform_remote_state.vpc.private_zone_name}"
  certificate_arn              = "${data.aws_acm_certificate.cert.arn}"
  weblogic_health_check_path   = "NDelius-war/delius/JSP/healthcheck.jsp"
  weblogic_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  weblogic_tls_port            = "${var.weblogic_domain_ports["weblogic_tls_port"]}"
  activemq_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  activemq_enabled             = "true"
  umt_asg_id                   = "${data.terraform_remote_state.umt.asg["id"]}"

  app_bootstrap_name           = "hmpps-delius-core-bootstrap"
  app_bootstrap_src            = "https://github.com/ministryofjustice/hmpps-delius-core-bootstrap"
  app_bootstrap_version        = "master"
  app_bootstrap_initial_role   = "delius-core"
  app_bootstrap_secondary_role = "delius-spg"

  ansible_vars = {
    cldwatch_log_group       = "${var.environment_identifier}/weblogic-spg"

    # Artefact locations
    s3_dependencies_bucket   = "${substr("${var.dependencies_bucket_arn}", 13, -1)}"

    # Server/WebLogic config
    domain_name              = "${local.ansible_vars["domain_name"]}"
    server_name              = "${local.ansible_vars["server_name"]}"
    jvm_mem_args             = "${local.ansible_vars["jvm_mem_args"]}"
    server_params            = "${local.ansible_vars["jvm_mem_args"]} -XX:MaxPermSize=256m"
    weblogic_admin_username  = "${local.ansible_vars["weblogic_admin_username"]}"
    server_listen_address    = "${local.ansible_vars["server_listen_address"]}"
    server_listen_port       = "${var.weblogic_domain_ports["weblogic_port"]}"

    # Database
    setup_datasources        = "${local.ansible_vars["setup_datasources"]}"
    primary_db_host          = "${data.terraform_remote_state.database_failover.public_fqdn_delius_db_1}"
    database_url             = "${data.terraform_remote_state.database_failover.jdbc_failover_url}"

    # Alfresco
    alfresco_host            = "${local.ansible_vars["alfresco_host"]}.${data.aws_route53_zone.public.name}"
    alfresco_port            = "${local.ansible_vars["alfresco_port"]}"
    alfresco_office_host     = "${local.ansible_vars["alfresco_office_host"]}.${data.aws_route53_zone.public.name}"
    alfresco_office_port     = "${local.ansible_vars["alfresco_office_port"]}"

    # SPG
    spg_jms_host             = "${local.ansible_vars["spg_jms_host"]}.${data.aws_route53_zone.public.name}"
    activemq_data_folder     = "${local.ansible_vars["activemq_data_folder"]}"

    # LDAP
    ldap_host                = "${data.terraform_remote_state.ldap.private_fqdn_ldap_elb}"
    ldap_readonly_host       = "${data.terraform_remote_state.ldap.private_fqdn_ldap_elb}"
    ldap_port                = "${var.ldap_ports["ldap"]}"
    ldap_principal           = "${data.terraform_remote_state.ldap.ldap_bind_user}"
    ldap_base                = "${data.terraform_remote_state.ldap.ldap_base}"
    ldap_user_base           = "${data.terraform_remote_state.ldap.ldap_base_users}"
    ldap_group_base          = "cn=EISUsers,${data.terraform_remote_state.ldap.ldap_base_users}"

    # App config
    ndelius_display_name     = "${local.ansible_vars["ndelius_display_name"]}"
    ndelius_training_mode    = "${local.ansible_vars["ndelius_training_mode"]}"
    ndelius_log_level        = "${local.ansible_vars["ndelius_log_level"]}"
    ndelius_analytics_tag    = "${local.ansible_vars["ndelius_analytics_tag"]}"
    ldap_passfile            = "${local.ansible_vars["ldap_passfile"]}"

    # Newtech
    newtech_search_url       = "${local.ansible_vars["newtech_search_url"]}"
    newtech_pdfgenerator_url = "${local.ansible_vars["newtech_pdfgenerator_url"]}"
    newtech_pdfgenerator_templates = "${local.ansible_vars["newtech_pdfgenerator_templates"]}"
    newtech_pdfgenerator_secret = "${local.ansible_vars["newtech_pdfgenerator_secret"]}"

    # User Management Tool
    usermanagement_url       = "${local.ansible_vars["usermanagement_url"]}"

    # NOMIS
    nomis_url                = "${local.ansible_vars["nomis_url"]}"
    nomis_client_id          = "${local.ansible_vars["nomis_client_id"]}"
    nomis_client_secret      = "${local.ansible_vars["nomis_client_secret"]}"

    ## the following are retrieved from SSM Parameter Store
    ## weblogic_admin_password  = "/${environment_name}/delius-core/weblogic/${app_name}-domain/weblogic_admin_password"
    ## database_password        = "/${environment_name}/${project}/delius-database/db/delius_pool_password"
    ## ldap_admin_password      = "/${environment_name}/delius-core/apacheds/apacheds/ldap_admin_password"
  }
}

output "ami_spg_wls" {
  value = "${data.aws_ami.centos_wls.id} - ${data.aws_ami.centos_wls.name}"
}

output "private_fqdn_spg_wls_internal_alb" {
  value = "${module.spg.private_fqdn_internal_alb}"
}

output "newtech_webfrontend_target_group_arn" {
  value = "${module.spg.newtech_webfrontend_targetgroup_arn}"
}