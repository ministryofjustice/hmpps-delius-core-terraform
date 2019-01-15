module "master_launch_cfg" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//launch_configuration//noblockdevice"
  launch_configuration_name   = "${var.environment_name}-${var.tier_name}-master"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  volume_size                 = 50
  volume_type                 = "gp2"
  instance_profile            = "${var.iam_instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_groups}"]
  user_data                   = "${data.template_file.user_data.rendered}"
}

module "master_asg" {
  source                = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//autoscaling//group//asg_classic_lb"
  asg_name              = "${var.environment_name}-${var.tier_name}-master"
  asg_min               = 1
  asg_desired           = 1
  asg_max               = 1
  launch_configuration  = "${module.master_launch_cfg.launch_name}"
  load_balancers        = ["${aws_elb.ldap_master_lb.id}"]
  subnet_ids            = ["${var.private_subnets}"]
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-master-asg"))}"
}
