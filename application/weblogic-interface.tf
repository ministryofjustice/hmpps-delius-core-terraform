# Weblogic tier interface

module "interface" {
  # source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//weblogic-admin-only"
  source               = "../modules/weblogic-admin-only"
  tier_name            = "interface"
  ami_id               = "${data.aws_ami.centos_wls.id}"
  instance_type        = "${var.instance_type_weblogic}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${module.s3_access_role.instance_profile_ec2_id}"

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
  environment_type             = "${var.environment_type}"
  region                       = "${var.region}"
  vpc_id                       = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_account_id               = "${data.terraform_remote_state.vpc.vpc_account_id}"
  kms_key_id                   = "${module.kms_key_app.kms_arn}"
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

  app_bootstrap_name = "hmpps-delius-core-bootstrap"
  app_bootstrap_src =  "https://github.com/ministryofjustice/hmpps-delius-core-bootstrap"
  app_bootstrap_version = "feature/bootstrap_application_vm"
  app_bootstrap_initial_role = "delius-core"
  app_bootstrap_secondary_role = "delius-interfaces"
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
