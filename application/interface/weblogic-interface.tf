# Weblogic tier interface

module "interface" {
  # source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//weblogic-admin-only"
  source               = "../../modules/weblogic-admin-only"
  tier_name            = "interface"
  ami_id               = "${data.aws_ami.centos_wls.id}"
  instance_type        = "${var.instance_type_weblogic}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_admin_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_managed_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
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

  tags                         = "${data.terraform_remote_state.vpc.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"
  short_environment_name       = "${var.short_environment_name}"
  environment_type             = "${var.environment_type}"
  region                       = "${var.region}"
  vpc_id                       = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_account_id               = "${data.terraform_remote_state.vpc.vpc_account_id}"
  kms_key_id                   = "${data.terraform_remote_state.key_profile.kms_arn_app}"
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id              = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_domain               = "${data.terraform_remote_state.vpc.private_zone_name}"
  admin_elb_sg_id              = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_admin_elb_id}"
  managed_elb_sg_id            = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_managed_elb_id}"
  admin_port                   = "${var.weblogic_domain_ports["interface_admin"]}"
  managed_port                 = "${var.weblogic_domain_ports["interface_managed"]}"

  admin_health_check = {
    path    = "/NDelius-war"
    matcher = "200,302"
  }

  managed_health_check = {
    path    = "/NDelius-war"
    matcher = "200,302"
  }

  app_bootstrap_name            = "hmpps-delius-core-bootstrap"
  app_bootstrap_src             =  "https://github.com/ministryofjustice/hmpps-delius-core-bootstrap"
  app_bootstrap_version         = "master"
  app_bootstrap_initial_role    = "delius-core"
  app_bootstrap_secondary_role  = "delius-interfaces"

  ndelius_version = "${var.ndelius_version}"

  ansible_vars = {
    setup_datasources        = "${var.ansible_vars["setup_datasources"]}"
    s3_dependencies_bucket   = "${substr("${var.dependencies_bucket_arn}", 13, -1)}"
    database_host            = "${var.ansible_vars["database_host"]}.${data.aws_route53_zone.public.name}"
    alfresco_host            = "${var.ansible_vars["alfresco_host"]}.${data.aws_route53_zone.public.name}"
    alfresco_office_host     = "${var.ansible_vars["alfresco_office_host"]}.${data.aws_route53_zone.public.name}"
    spg_host                 = "${var.ansible_vars["spg_host"]}.${data.aws_route53_zone.public.name}"
    ldap_host                = "${var.ansible_vars["ldap_host"]}.${data.aws_route53_zone.public.name}"

    ndelius_display_name     = "${var.ansible_vars["ndelius_display_name"]}"
    ndelius_training_mode    = "${var.ansible_vars["ndelius_training_mode"]}"
    ndelius_log_level        = "${var.ansible_vars["ndelius_log_level"]}"
    ndelius_analytics_tag    = "${var.ansible_vars["ndelius_analytics_tag"]}"
    newtech_search_url       = "${var.ansible_vars["newtech_search_url"]}"
    newtech_pdfgenerator_url = "${var.ansible_vars["newtech_pdfgenerator_url"]}"
    usermanagement_url       = "${var.ansible_vars["usermanagement_url"]}"
    nomis_url                = "${var.ansible_vars["nomis_url"]}"

    domain_name              = "${var.ansible_vars["domain_name"]}"
    server_name              = "${var.ansible_vars["server_name"]}"
    server_params            = "${var.ansible_vars["server_params"]}"
    weblogic_admin_username  = "${var.ansible_vars["weblogic_admin_username"]}"
    server_listen_address    = "${var.ansible_vars["server_listen_address"]}"
    server_listen_port       = "${var.weblogic_domain_ports["ndelius_admin"]}"
    jvm_mem_args             = "${var.ansible_vars["jvm_mem_args"]}"
    database_port            = "${var.ansible_vars["database_port"]}"
    database_sid             = "${var.ansible_vars["database_sid"]}"

    alfresco_port           = "${var.ansible_vars["alfresco_port"]}"
    alfresco_office_port    = "${var.ansible_vars["alfresco_office_port"]}"

    ldap_port               = "${var.ldap_ports["ldap"]}"
    ldap_principal          = "${var.ansible_vars_apacheds["bind_user"]}"
    partition_id            = "${var.ansible_vars_apacheds["partition_id"]}"

    ## the following are retrieved from SSM Parameter Store
    ##
    ## weblogic_admin_password    = "/${environment_name}/delius-core/weblogic/${app_name}-domain/weblogic_admin_password"
    ## database_password          = "/${environment_name}/delius-core/oracle-database/db/delius_app_schema_password"
    ## ldap_admin_password        = "/${environment_name}/delius-core/apacheds/apacheds/ldap_admin_password"
  }
}

output "ami_interface_wls" {
  value = "${data.aws_ami.centos_wls.id} - ${data.aws_ami.centos_wls.name}"
}

output "internal_fqdn_interface_wls" {
  value = "${module.interface.internal_fqdn_wls}"
}

output "public_fqdn_interface_wls" {
  value = "${module.interface.public_fqdn_wls}"
}

output "private_ip_interface_wls" {
  value = "${module.interface.private_ip_wls}"
}

output "internal_fqdn_interface_wls_admin_lb" {
  value = "${module.interface.internal_fqdn_admin_lb}"
}

output "public_fqdn_interface_wls_admin_lb" {
  value = "${module.interface.public_fqdn_admin_lb}"
}

output "internal_fqdn_interface_managed_lb" {
  value = "${module.interface.internal_fqdn_managed_lb}"
}

output "public_fqdn_interface_managed_lb" {
  value = "${module.interface.public_fqdn_managed_lb}"
}
