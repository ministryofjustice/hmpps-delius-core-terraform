module "launch_cfg" {
  source                      = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//launch_configuration//noblockdevice"
  launch_configuration_name   = "${var.environment_name}-${var.tier_name}-ldap-master-launch-config"
  image_id                    = "${aws_instance.ldap.ami}"
  instance_type               = "${aws_instance.ldap.instance_type}"
  volume_size                 = 50
  volume_type                 = "gp2"
  instance_profile            = "${aws_instance.ldap.iam_instance_profile}"
  key_name                    = "${aws_instance.ldap.key_name}"
  security_groups             = ["${aws_instance.ldap.vpc_security_group_ids}"]
  user_data                   = "${data.template_file.user_data.rendered}"
}

module "master_asg" {
  source                = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=pre-shared-vpc//modules//autoscaling//group//asg_classic_lb"
  asg_name              = "${var.environment_name}-${var.tier_name}-ldap-master-asg"
  asg_min               = 1
  asg_max               = 1
  asg_desired           = 1
  launch_configuration  = "${module.launch_cfg.launch_name}"
  load_balancers        = ["${aws_elb.ldap_internal_lb.id}"]
  subnet_ids            = ["${var.private_subnets}"]
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-ldap-master-asg"))}"
}
