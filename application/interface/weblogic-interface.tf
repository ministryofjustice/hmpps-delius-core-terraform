# Weblogic tier interface

locals {
  # Override default values
  ansible_vars = "${merge(${var.default_ansible_vars}, ${var.ansible_vars})}"
}

module "interface" {
  # source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//weblogic-admin-only"
  source               = "../../modules/weblogic-admin-only"
  tier_name            = "interface"
  ami_id               = "${data.aws_ami.centos_wls.id}"
  instance_type        = "${var.instance_type_weblogic}"
  instance_count       = "${var.instance_count_weblogic_interface}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_instances_id}",
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

  tags                         = "${var.tags}"
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
  certificate_arn              = "${data.aws_acm_certificate.cert.arn}"
  internal_elb_sg_id           = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_internal_elb_id}"
  external_elb_sg_id           = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_interface_external_elb_id}"
  weblogic_health_check_path   = "NDelius-war/delius/JSP/healthcheck.jsp"
  weblogic_port                = "${var.weblogic_domain_ports["weblogic_port"]}"
  weblogic_tls_port            = "${var.weblogic_domain_ports["weblogic_tls_port"]}"
  activemq_port                = "${var.weblogic_domain_ports["activemq_port"]}"
  activemq_enabled             = "false"

  app_bootstrap_name            = "hmpps-delius-core-bootstrap"
  app_bootstrap_src             =  "https://github.com/ministryofjustice/hmpps-delius-core-bootstrap"
  app_bootstrap_version         = "master"
  app_bootstrap_initial_role    = "delius-core"
  app_bootstrap_secondary_role  = "delius-interfaces"

  ndelius_version = "${var.ndelius_version}"

  ansible_vars = "${merge(${local.ansible_vars}, map(
      "cldwatch_log_group", "${var.environment_identifier}/weblogic-interface",
      "database_url", concat("(DESCRIPTION=(LOAD_BALANCE=OFF)(FAILOVER=ON)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=",
        "(ADDRESS=(PROTOCOL=tcp)(HOST=delius-db-1.${data.aws_route53_zone.public.name})(PORT=1521))",
        "(ADDRESS=(PROTOCOL=tcp)(HOST=delius-db-2.${data.aws_route53_zone.public.name})(PORT=1521))",
        "(ADDRESS=(PROTOCOL=tcp)(HOST=delius-db-3.${data.aws_route53_zone.public.name})(PORT=1521)))",
        "(CONNECT_DATA=(SERVICE_NAME=${local.ansible_vars["database_sid"]}_TAF)))"),
      "alfresco_host", "${local.ansible_vars["alfresco_host"]}.${data.aws_route53_zone.public.name}",
      "alfresco_office_host", "${local.ansible_vars["alfresco_office_host"]}.${data.aws_route53_zone.public.name}",
      "spg_host", "${local.ansible_vars["spg_host"]}.${data.aws_route53_zone.public.name}",
      "ldap_host", "${local.ansible_vars["ldap_host"]}.${data.aws_route53_zone.public.name}",
      "ldap_principal", "${var.ansible_vars_apacheds["bind_user"]}",
      "partition_id", "${var.ansible_vars_apacheds["partition_id"]}"
    ))}"
}

output "ami_interface_wls" {
  value = "${data.aws_ami.centos_wls.id} - ${data.aws_ami.centos_wls.name}"
}

output "private_fqdn_interface_wls_internal_lb" {
  value = "${module.interface.private_fqdn_internal_lb}"
}

output "public_fqdn_interface_wls_internal_lb" {
  value = "${module.interface.public_fqdn_internal_lb}"
}

output "private_fqdn_interface_external_lb" {
  value = "${module.interface.private_fqdn_external_lb}"
}

output "public_fqdn_interface_external_lb" {
  value = "${module.interface.public_fqdn_external_lb}"
}
