# ApacheDS LDAP
locals {
  # Override default values
  ansible_vars_apacheds = "${merge(var.default_ansible_vars_apacheds, var.ansible_vars_apacheds)}"
}

module "ldap" {
  source               = "../../modules/apacheds-ldap"
  tier_name            = "ldap"
  ami_id               = "${data.aws_ami.centos_apacheds.id}"
  instance_type        = "${var.instance_type_ldap}"
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
  private_zone_id              = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_domain               = "${data.terraform_remote_state.vpc.private_zone_name}"
  admin_elb_sg_id              = "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_private_elb_id}"
  ldap_port                    = "${var.ldap_ports["ldap"]}"

  app_bootstrap_name         = "hmpps-delius-core-apacheds-bootstrap"
  app_bootstrap_src          = "https://github.com/ministryofjustice/hmpps-delius-core-apacheds-bootstrap"
  app_bootstrap_version      = "master"
  app_bootstrap_initial_role = "hmpps-delius-core-apacheds-bootstrap"

  ndelius_version = "${var.ndelius_version}"

  ansible_vars = {
    # AWS
    cldwatch_log_group         = "${var.environment_identifier}/ldap"
    s3_dependencies_bucket     = "${substr("${var.dependencies_bucket_arn}", 13, -1)}"
    s3_backups_bucket          = "${var.environment_identifier}-backups-s3bucket"

    # ApacheDS
    jvm_mem_args               = "${local.ansible_vars_apacheds["jvm_mem_args"]}"
    apacheds_version           = "${local.ansible_vars_apacheds["apacheds_version"]}"
    apacheds_install_directory = "${local.ansible_vars_apacheds["apacheds_install_directory"]}"
    apacheds_lib_directory     = "${local.ansible_vars_apacheds["apacheds_lib_directory"]}"
    workspace                  = "${local.ansible_vars_apacheds["workspace"]}"
    log_level                  = "${local.ansible_vars_apacheds["log_level"]}"

    # LDAP
    ldap_protocol              = "${local.ansible_vars_apacheds["ldap_protocol"]}"
    ldap_port                  = "${var.ldap_ports["ldap"]}"
    bind_user                  = "${local.ansible_vars_apacheds["bind_user"]}"
    # bind_password            = "/${environment_name}/delius-core/apacheds/apacheds/ldap_admin_password"
    partition_id               = "${local.ansible_vars_apacheds["partition_id"]}"
    base_root                  = "${local.ansible_vars_apacheds["base_root"]}"

    # Data import
    import_users_ldif          = "${local.ansible_vars_apacheds["import_users_ldif"]}"
    sanitize_oid_ldif          = "${local.ansible_vars_apacheds["sanitize_oid_ldif"]}"
  }
}

output "ami_ldap_wls" {
  value = "${data.aws_ami.centos_apacheds.id} - ${data.aws_ami.centos_apacheds.name}"
}

output "private_fqdn_ldap_internal_lb" {
  value = "${module.ldap.private_fqdn_ldap_elb}"
}

output "public_fqdn_ldap_internal_lb" {
  value = "${module.ldap.public_fqdn_ldap_elb}"
}
