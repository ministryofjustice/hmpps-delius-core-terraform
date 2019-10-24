module "external_nlb" {
  source               = "../modules/nlb_to_alb"
  tier_name            = "pwm"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  eip_allocation_ids   = [
    "${data.terraform_remote_state.persistent-eip.delius_pwm_az1_lb_eip.allocation_id}",
    "${data.terraform_remote_state.persistent-eip.delius_pwm_az2_lb_eip.allocation_id}",
    "${data.terraform_remote_state.persistent-eip.delius_pwm_az3_lb_eip.allocation_id}",
  ]

  haproxy_security_groups = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_pwm_lb_id}",
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
  public_zone_id               = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id              = "${data.terraform_remote_state.vpc.private_zone_id}"
  private_domain               = "${data.terraform_remote_state.vpc.private_zone_name}"
  alb_fqdn                     = "${aws_route53_record.internal_lb_private_dns.fqdn}"
  haproxy_instance_type        = "${var.delius_core_haproxy_instance_type}"
  haproxy_instance_count       = "${var.delius_core_haproxy_instance_count}"
  aws_nameserver               = "${var.aws_nameserver}"
}
