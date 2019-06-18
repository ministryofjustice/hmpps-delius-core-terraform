data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"
  vars {
    ecs_cluster_name = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_launch_configuration" "launch_cfg" {
  name_prefix          = "${var.short_environment_name}-pwm-launch-cfg-"
  image_id             = "${data.aws_ami.ecs_ami.id}"
  iam_instance_profile = "${aws_iam_instance_profile.ecs.id}"
  instance_type        = "t2.medium"
  security_groups      = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_pwm_instances_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
  ]
  enable_monitoring    = "true"
  user_data            = "${data.template_file.user_data.rendered}"
  root_block_device {
    volume_type        = "gp2"
    volume_size        = 50
  }
  lifecycle {
    create_before_destroy = true
  }
}

# This null_data_source is required to convert our Map of tags, to the required List of tags for ASGs
# see: https://github.com/hashicorp/terraform/issues/16980
data "null_data_source" "tags" {
  count = "${length(keys(var.tags))}"
  inputs = {
    key                 = "${element(keys(var.tags), count.index)}"
    value               = "${element(values(var.tags), count.index)}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.environment_name}-pwm"
  vpc_zone_identifier       = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3
  )}"]
  launch_configuration      = "${aws_launch_configuration.launch_cfg.id}"
  min_size                  = "1"
  max_size                  = "3"
  desired_capacity          = "1"
  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${var.environment_name}-pwm"
      propagate_at_launch = true
    }
  ]
  lifecycle {
    create_before_destroy = true
  }
}