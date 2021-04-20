# Shared NFS for the ActiveMQ persistence store
#
# *DEPRECATED* - See efs.tf.
# Note: This NFS module is still in use until the data has been migrated to EFS in all environments.
#

#Overide autostop tag
locals {
  tags = merge(var.tags, { "autostop-${var.environment_type}" = "Phase1" })
}

module "activemq-nfs" {
  source                       = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules/nfs-server?ref=terraform-0.12"
  region                       = var.region
  app_name                     = "amq-nfs"
  environment_identifier       = var.environment_identifier
  short_environment_identifier = var.short_environment_identifier
  remote_state_bucket_name     = var.remote_state_bucket_name
  route53_sub_domain           = data.aws_route53_zone.public.name
  bastion_origin_sgs           = [data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id]
  private-cidr                 = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  private_subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
  availability_zones = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1-availability_zone,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2-availability_zone,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3-availability_zone,
  ]
  tags = local.tags
}

