module "delius_db" {
  source      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//oracle-database"
  server_name = "delius-db"

  ami_id               = "${data.aws_ami.centos_oracle_db.id}"
  instance_type        = "${var.instance_type_db}"
  db_subnet            = "${data.terraform_remote_state.vpc.vpc_db-subnet-az1}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_delius_db_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_delius_db_out_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
  ]

  tags                         = "${data.terraform_remote_state.vpc.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"

  environment_type = "${var.environment_type}"
  region           = "${var.region}"

  kms_key_id      = "${data.terraform_remote_state.key_profile.kms_arn_app}"
  public_zone_id  = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_domain  = "${data.terraform_remote_state.vpc.private_zone_name}"
  vpc_account_id  = "${data.terraform_remote_state.vpc.vpc_account_id}"
}

output "ami_delius_db" {
  value = "${data.aws_ami.centos_oracle_db.id} - ${data.aws_ami.centos_oracle_db.name}"
}

output "public_fqdn_delius_db" {
  value = "${module.delius_db.public_fqdn}"
}

output "internal_fqdn_delius_db" {
  value = "${module.delius_db.internal_fqdn}"
}

output "private_ip_delius_db" {
  value = "${module.delius_db.private_ip}"
}
