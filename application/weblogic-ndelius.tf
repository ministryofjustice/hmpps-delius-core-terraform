# Weblogic tier ndelius

module "ndelius" {
  source              = "../modules/weblogic"
  tier_name           = "ndelius"
  admin_port          = "${var.weblogic_domain_ports["ndelius_admin"]}"
  admin_instance_type = "${var.instance_type_weblogic}"

  admin_security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_ndelius_admin_id}",
  ]

  managed_port          = "${var.weblogic_domain_ports["ndelius_managed"]}"
  managed_instance_type = "${var.instance_type_weblogic}"

  managed_security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_ndelius_managed_id}",
  ]

  private_subnet = "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}"

  public_subnets = "${list(
    data.terraform_remote_state.vpc.vpc_public-subnet-az1,
    data.terraform_remote_state.vpc.vpc_public-subnet-az2,
    data.terraform_remote_state.vpc.vpc_public-subnet-az3,
  )}"

  tags                 = "${data.terraform_remote_state.vpc.tags}"
  environment_name     = "${data.terraform_remote_state.vpc.environment_name}"
  environment_identifier = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"
  environment_type = "${var.environment_type}"
  region               = "${var.region}"
  vpc_id               = "${data.terraform_remote_state.vpc.vpc_id}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  kms_key_id           = "${module.kms_key_app.kms_arn}"
  public_zone_id       = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id      = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_domain       = "${data.terraform_remote_state.vpc.private_zone_name}"
  vpc_account_id       = "${data.terraform_remote_state.vpc.vpc_account_id}"
  ami_id               = "${data.aws_ami.centos_wls.id}"
  managed_elb_sg_id    = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_ndelius_managed_elb_id}"
  admin_elb_sg_id      = "${data.terraform_remote_state.delius_core_security_groups.sg_weblogic_ndelius_admin_elb_id}"
  iam_instance_profile = "${module.s3_access_role.instance_profile_ec2_id}"
}

output "internal_fqdn_ndelius_admin" {
  value = "${module.ndelius.internal_fqdn_admin}"
}

output "public_fqdn_ndelius_admin" {
  value = "${module.ndelius.public_fqdn_admin}"
}

output "private_ip_ndelius_admin" {
  value = "${module.ndelius.private_ip_admin}"
}

output "internal_fqdn_ndelius_admin_lb" {
  value = "${module.ndelius.internal_fqdn_admin_lb}"
}

output "public_fqdn_ndelius_admin_lb" {
  value = "${module.ndelius.public_fqdn_admin_lb}"
}

#
output "internal_fqdn_ndelius_managed" {
  value = "${module.ndelius.internal_fqdn_managed}"
}

output "public_fqdn_ndelius_managed" {
  value = "${module.ndelius.public_fqdn_managed}"
}

output "private_ip_ndelius_managed" {
  value = "${module.ndelius.private_ip_managed}"
}

output "internal_fqdn_ndelius_managed_lb" {
  value = "${module.ndelius.internal_fqdn_managed_lb}"
}

output "public_fqdn_ndelius_managed_lb" {
  value = "${module.ndelius.public_fqdn_managed_lb}"
}
