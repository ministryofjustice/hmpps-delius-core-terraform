#TODO: ASG for managed should nightly cycle boxes

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
    project_name                  = "${var.project_name}"
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    app_name                      = "${var.tier_name}"
    route53_sub_domain            = "${var.environment_name}"
    environment_name              = "${var.environment_name}"
    private_domain                = "${var.private_domain}"
    account_id                    = "${var.vpc_account_id}"
    bastion_inventory             = "${var.bastion_inventory}"
    app_bootstrap_name            = "${var.app_bootstrap_name}"
    app_bootstrap_src             = "${var.app_bootstrap_src}"
    app_bootstrap_version         = "${var.app_bootstrap_version}"
    app_bootstrap_initial_role    = "${var.app_bootstrap_initial_role}"
    app_bootstrap_secondary_role  = "${var.app_bootstrap_secondary_role}"
    app_bootstrap_tertiary_role   = "${var.app_bootstrap_tertiary_role}"

    # AWS
    cldwatch_log_group            = "${var.ansible_vars["cldwatch_log_group"]}"
    s3_dependencies_bucket        = "${var.ansible_vars["s3_dependencies_bucket"]}"
    s3_backups_bucket             = "${var.ansible_vars["s3_backups_bucket"]}"

    # ApacheDS
    jvm_mem_args                  = "${var.ansible_vars["jvm_mem_args"]}"
    apacheds_version              = "${var.ansible_vars["apacheds_version"]}"
    apacheds_install_directory    = "${var.ansible_vars["apacheds_install_directory"]}"
    apacheds_lib_directory        = "${var.ansible_vars["apacheds_lib_directory"]}"
    workspace                     = "${var.ansible_vars["workspace"]}"
    log_level                     = "${var.ansible_vars["log_level"]}"

    # LDAP
    ldap_protocol                 = "${var.ansible_vars["ldap_protocol"]}"
    ldap_port                     = "${var.ansible_vars["ldap_port"]}"
    bind_user                     = "${var.ansible_vars["bind_user"]}"
    # bind_password               = "/TG_ENVIRONMENT_NAME/TG_PROJECT_NAME/apacheds/apacheds/ldap_admin_password"
    partition_id                  = "${var.ansible_vars["partition_id"]}"
    base_root                     = "${var.ansible_vars["base_root"]}"
    is_consumer                   = "false"
    provider_host                 = "localhost"

    # Data import
    import_users_ldif             = "${var.ansible_vars["import_users_ldif"]}"
    sanitize_oid_ldif             = "${var.ansible_vars["sanitize_oid_ldif"]}"
  }
}

data "template_file" "user_data_slave" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
    project_name                  = "${var.project_name}"
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    app_name                      = "${var.tier_name}"
    route53_sub_domain            = "${var.environment_name}"
    environment_name              = "${var.environment_name}"
    private_domain                = "${var.private_domain}"
    account_id                    = "${var.vpc_account_id}"
    bastion_inventory             = "${var.bastion_inventory}"
    app_bootstrap_name            = "${var.app_bootstrap_name}"
    app_bootstrap_src             = "${var.app_bootstrap_src}"
    app_bootstrap_version         = "${var.app_bootstrap_version}"
    app_bootstrap_initial_role    = "${var.app_bootstrap_initial_role}"
    app_bootstrap_secondary_role  = "${var.app_bootstrap_secondary_role}"
    app_bootstrap_tertiary_role   = "${var.app_bootstrap_tertiary_role}"

    # AWS
    cldwatch_log_group            = "${var.ansible_vars["cldwatch_log_group"]}"
    s3_dependencies_bucket        = "${var.ansible_vars["s3_dependencies_bucket"]}"
    s3_backups_bucket             = "${var.ansible_vars["s3_backups_bucket"]}"

    # ApacheDS
    jvm_mem_args                  = "${var.ansible_vars["jvm_mem_args"]}"
    apacheds_version              = "${var.ansible_vars["apacheds_version"]}"
    apacheds_install_directory    = "${var.ansible_vars["apacheds_install_directory"]}"
    apacheds_lib_directory        = "${var.ansible_vars["apacheds_lib_directory"]}"
    workspace                     = "${var.ansible_vars["workspace"]}"
    log_level                     = "${var.ansible_vars["log_level"]}"

    # LDAP
    ldap_protocol                 = "${var.ansible_vars["ldap_protocol"]}"
    ldap_port                     = "${var.ansible_vars["ldap_port"]}"
    bind_user                     = "${var.ansible_vars["bind_user"]}"
    # bind_password               = "/TG_ENVIRONMENT_NAME/TG_PROJECT_NAME/apacheds/apacheds/ldap_admin_password"
    partition_id                  = "${var.ansible_vars["partition_id"]}"
    base_root                     = "${var.ansible_vars["base_root"]}"
    is_consumer                   = "true"
    provider_host                 = "${aws_route53_record.ldap_elb_private.fqdn}"

    # Data import
    import_users_ldif             = "${var.ansible_vars["import_users_ldif"]}"
    sanitize_oid_ldif             = "${var.ansible_vars["sanitize_oid_ldif"]}"
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
