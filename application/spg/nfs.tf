# Shared NFS for the ActiveMQ persistence store

#Overide autostop tag
locals {
  tags = "${merge(
    var.tags,
    map("autostop-${var.environment_type}", "Phase1")
  )}"
}

module "activemq-nfs" {
  source                        = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//nfs-server"
  region                        = "${var.region}"
  app_name                      = "amq-nfs"
  environment_identifier        = "${var.environment_identifier}"
  short_environment_identifier  = "${var.short_environment_identifier}"
  remote_state_bucket_name      = "${var.remote_state_bucket_name}"
  route53_sub_domain            = "${data.aws_route53_zone.public.name}"
  bastion_origin_sgs            = ["${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}"]
  private-cidr                  = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  private_subnet_ids            = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}",
  ]
  availability_zones            = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1-availability_zone}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2-availability_zone}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3-availability_zone}",
  ]
  tags                          = "${local.tags}"
}
