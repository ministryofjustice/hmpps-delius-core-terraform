locals {
  server_name = "omnia-db-1"

  ami_id        = data.aws_ami.base_centos.id
  instance_type = "t3.2xlarge"
  db_subnet     = data.terraform_remote_state.vpc.outputs.vpc_db-subnet-az1
  key_name      = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
  role_name     = "omnia-db"

  security_group_ids = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    aws_security_group.omnia_db_in.id,
    aws_security_group.omnia_db_out.id,
  ]

  tags                         = var.tags
  environment_name             = data.terraform_remote_state.vpc.outputs.environment_name
  bastion_inventory            = data.terraform_remote_state.vpc.outputs.bastion_inventory
  project_name                 = var.project_name
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier

  environment_type = var.environment_type
  region           = var.region

  kms_key_id      = data.terraform_remote_state.key_profile.outputs.kms_arn_app
  public_zone_id  = data.terraform_remote_state.vpc.outputs.public_zone_id
  private_zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  private_domain  = data.terraform_remote_state.vpc.outputs.private_zone_name
  vpc_account_id  = data.terraform_remote_state.vpc.outputs.vpc_account_id

  dependencies_bucket_arn = var.dependencies_bucket_arn
  s3_omnia_data_arn       = "arn:aws:s3:::tf-eu-west-2-hmpps-eng-prod-omnia-data-s3bucket"
}
