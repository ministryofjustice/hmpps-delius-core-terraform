data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
    project_name                  = "${var.project_name}"
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    app_name                      = "ldap"
    route53_sub_domain            = "${var.environment_name}"
    environment_name              = "${var.environment_name}"
    private_domain                = "${data.terraform_remote_state.vpc.private_zone_name}"
    account_id                    = "${data.terraform_remote_state.vpc.vpc_account_id}"
    bastion_inventory             = "${data.terraform_remote_state.vpc.bastion_inventory}"

    app_bootstrap_name            = "ldap"
    app_bootstrap_src             = "https://github.com/ministryofjustice/hmpps-delius-core-ldap-bootstrap"
    app_bootstrap_version         = "master"
# Ansible vars:
    workspace                     = "${local.ansible_vars_apacheds["workspace"]}"

    # AWS
    cldwatch_log_group            = "${var.environment_identifier}/ldap"
    s3_dependencies_bucket        = "${substr("${var.dependencies_bucket_arn}", 13, -1)}"
    s3_backups_bucket             = "${data.terraform_remote_state.s3-ldap-backups.s3_ldap_backups.name}"

    # LDAP
    ldap_protocol                 = "${local.ansible_vars_apacheds["ldap_protocol"]}"
    ldap_port                     = "${var.ldap_ports["ldap"]}"
    bind_user                     = "${local.ansible_vars_apacheds["bind_user"]}"
    # bind_password               = "/TG_ENVIRONMENT_NAME/TG_PROJECT_NAME/apacheds/apacheds/ldap_admin_password"
    base_root                     = "${local.ansible_vars_apacheds["base_root"]}"
    base_users                    = "${local.ansible_vars_apacheds["base_users"]}"

    # Data import
    import_users_ldif             = "${local.ansible_vars_apacheds["import_users_ldif"]}"
    import_users_ldif_base_users  = "${local.ansible_vars_apacheds["import_users_ldif_base_users"]}"
    sanitize_oid_ldif             = "${local.ansible_vars_apacheds["sanitize_oid_ldif"]}"
    perf_test_users               = "${local.ansible_vars_apacheds["perf_test_users"]}"
  }
}

resource "aws_launch_configuration" "launch_cfg" {
  name_prefix                 = "${var.environment_name}-ldap-launch-cfg-"
  image_id                    = "${data.aws_ami.centos.id}"
  instance_type               = "${var.instance_type_ldap}"
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
  ebs_optimized               = "false"

  root_block_device {
    volume_type = "${var.ldap_disk_config["volume_type"]}"
    volume_size = "${var.ldap_disk_config["volume_size"]}"
    iops        = "${var.ldap_disk_config["iops"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${var.environment_name}-ldap"
  vpc_zone_identifier  = ["${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"]
  min_size             = "1"
  max_size             = "1"
  desired_capacity     = "1"
  launch_configuration = "${aws_launch_configuration.launch_cfg.id}"
  load_balancers       = ["${aws_elb.lb.id}"]

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
      key                 = "ndelius_version"
      value               = "None deployed"
      propagate_at_launch = true
    }
  ]
}
