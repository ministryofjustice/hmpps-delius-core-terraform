# Weblogic tier oid

module "ldap" {
  source               = "../../modules/apacheds-ldap"
  tier_name            = "ldap"
  ami_id               = "${data.aws_ami.centos_apacheds.id}"
  instance_type        = "${var.instance_type_weblogic}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_id}",
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
  admin_elb_sg_id              = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_oid_admin_elb_id}"
  managed_elb_sg_id            = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_oid_managed_elb_id}"
  admin_port                   = "${var.ldap_ports["ldap"]}"
  managed_port                 = "${var.ldap_ports["ldap"]}"

  # Place holder
  # admin_health_check = {
  #   path    = "/NDelius-war"
  #   matcher = "200,302"
  # }
  #
  # managed_health_check = {
  #   path    = "/NDelius-war"
  #   matcher = "200,302"
  # }
  app_bootstrap_name         = "hmpps-delius-core-apacheds-bootstrap"
  app_bootstrap_src          =  "https://github.com/ministryofjustice/hmpps-delius-core-apacheds-bootstrap"
  app_bootstrap_version      = "master"
  app_bootstrap_initial_role = "hmpps-delius-core-apacheds-bootstrap"

  ndelius_version = "${var.ndelius_version}"

  ansible_vars = {
    s3_dependencies_bucket = "${substr("${var.dependencies_bucket_arn}", 13, -1)}"
    apacheds_version       = "${var.ansible_vars_apacheds["apacheds_version"]}"
    ldap_protocol          = "${var.ansible_vars_apacheds["ldap_protocol"]}"
    ldap_port              = "${var.ldap_ports["ldap"]}"
    bind_user              = "${var.ansible_vars_apacheds["bind_user"]}"
    # bind_password        = "/TG_ENVIRONMENT_NAME/TG_PROJECT_NAME/apacheds/apacheds/ldap_admin_password"
    partition_id           = "${var.ansible_vars_apacheds["partition_id"]}"
    create_test_users      = "${var.ansible_vars_apacheds["create_test_users"]}"
  }
}

output "ami_ldap_wls" {
  value = "${data.aws_ami.centos_apacheds.id} - ${data.aws_ami.centos_apacheds.name}"
}

output "internal_fqdn_ldap_wls" {
  value = "${module.ldap.internal_fqdn_wls}"
}

output "public_fqdn_ldap_wls" {
  value = "${module.ldap.public_fqdn_wls}"
}

output "private_ip_ldap_wls" {
  value = "${module.ldap.private_ip_wls}"
}

output "internal_fqdn_ldap_wls_admin_lb" {
  value = "${module.ldap.internal_fqdn_admin_lb}"
}

output "public_fqdn_ldap_wls_admin_lb" {
  value = "${module.ldap.public_fqdn_admin_lb}"
}

output "internal_fqdn_ldap_managed_lb" {
  value = "${module.ldap.internal_fqdn_managed_lb}"
}

output "public_fqdn_ldap_managed_lb" {
  value = "${module.ldap.public_fqdn_managed_lb}"
}
