data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
    project_name          = "${var.project_name}"
    env_identifier        = "${var.environment_identifier}"
    short_env_identifier  = "${var.short_environment_identifier}"
    region                = "${var.region}"
    app_name              = "ldap"
    route53_sub_domain    = "${var.environment_name}"
    environment_name      = "${var.environment_name}"
    private_domain        = "${data.terraform_remote_state.vpc.private_zone_name}"
    account_id            = "${data.terraform_remote_state.vpc.vpc_account_id}"
    bastion_inventory     = "${data.terraform_remote_state.vpc.bastion_inventory}"

    app_bootstrap_name    = "ldap"
    app_bootstrap_src     = "https://github.com/ministryofjustice/hmpps-delius-core-ldap-bootstrap"
    app_bootstrap_version = "1.0.0"

    ldap_port             = "${local.ldap_config["port"]}"
    bind_user             = "${local.ldap_config["bind_user"]}"
    base_root             = "${local.ldap_config["base_root"]}"
    base_users            = "${local.ldap_config["base_users"]}"
    base_service_users    = "${local.ldap_config["base_service_users"]}"
    base_roles            = "${local.ldap_config["base_roles"]}"
    base_role_groups      = "${local.ldap_config["base_role_groups"]}"
    base_groups           = "${local.ldap_config["base_groups"]}"
    log_level             = "${local.ldap_config["log_level"]}"
    cldwatch_log_group    = "${var.environment_name}/ldap"
    s3_backups_bucket     = "${data.terraform_remote_state.s3-ldap-backups.s3_ldap_backups.name}"
    backup_frequency      = "${local.ldap_config["backup_frequency"]}"
    query_time_limit      = "${local.ldap_config["query_time_limit"]}"
    db_max_size           = "${local.ldap_config["db_max_size"]}"
    efs_dns_name          = "${aws_efs_file_system.efs.dns_name}"
  }
}

resource "aws_launch_configuration" "launch_cfg" {
  name_prefix                 = "${var.environment_name}-ldap-launch-cfg-"
  image_id                    = "${data.aws_ami.centos.id}"
  instance_type               = "${local.ldap_config["instance_type"]}"
  iam_instance_profile        = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"
  key_name                    = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  security_groups             = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_apacheds_ldap_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
  ]
  associate_public_ip_address = "false"
  user_data                   = "${data.template_file.user_data.rendered}"
  enable_monitoring           = "true"
  ebs_optimized               = "true"

  root_block_device {
    volume_type = "${local.ldap_config["disk_volume_type"]}"
    volume_size = "${local.ldap_config["disk_volume_size"]}"
    iops        = "${local.ldap_config["disk_iops"]}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["image_id"]
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.environment_name}-ldap"
  vpc_zone_identifier  = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"]
  min_size             = "${local.ldap_config["instance_count"]}"
  desired_capacity     = "${local.ldap_config["instance_count"]}"
  max_size             = "${local.ldap_config["instance_count"]}"
  launch_configuration = "${aws_launch_configuration.launch_cfg.id}"
  load_balancers       = ["${aws_elb.lb.id}"]
  health_check_type    = "EC2"
  enabled_metrics      = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
  lifecycle {
    create_before_destroy = true
  }

  tags = [
    "${data.null_data_source.tags.*.outputs}",
    {
      key                 = "Name"
      value               = "${var.environment_name}-ldap-asg"
      propagate_at_launch = true
    },
    {
      key                 = "rbac_version"
      value               = "None deployed"
      propagate_at_launch = true
    }
  ]
}
