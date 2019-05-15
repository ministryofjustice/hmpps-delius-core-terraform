resource "aws_launch_configuration" "slave_launch_cfg" {
  name_prefix                 = "${var.environment_name}-${var.tier_name}-slave-launch-cfg-"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.iam_instance_profile}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${var.security_groups}"]
  associate_public_ip_address = "false"
  user_data                   = "${data.template_file.user_data_slave.rendered}"
  enable_monitoring           = "true"
  ebs_optimized               = "false"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "slave_asg" {
  name                 = "${var.environment_name}-${var.tier_name}-slave"
  vpc_zone_identifier  = ["${var.private_subnets}"]
  min_size             = "${var.slave_asg_min}"
  max_size             = "${var.slave_asg_max}"
  desired_capacity     = "${var.slave_asg_desired}"
  launch_configuration = "${aws_launch_configuration.slave_launch_cfg.id}"
  load_balancers       = ["${aws_elb.ldap_readonly_lb.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tags = ["${data.null_data_source.tags.*.outputs}", {
    key                 = "Name"
    value               = "${var.environment_name}-${var.tier_name}-slave-asg"
    propagate_at_launch = true
  }]
}