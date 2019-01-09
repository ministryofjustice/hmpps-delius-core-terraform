#TODO: ASG for managed should nightly cycle boxes

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
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

    ndelius_version        = "${var.ndelius_version}"
    cldwatch_log_group     = "${var.ansible_vars["cldwatch_log_group"]}"
    s3_dependencies_bucket = "${var.ansible_vars["s3_dependencies_bucket"]}"
    apacheds_version       = "${var.ansible_vars["apacheds_version"]}"
    ldap_protocol          = "${var.ansible_vars["ldap_protocol"]}"
    ldap_port              = "${var.ansible_vars["ldap_port"]}"
    bind_user              = "${var.ansible_vars["bind_user"]}"
    # bind_password        = "/TG_ENVIRONMENT_NAME/TG_PROJECT_NAME/apacheds/apacheds/ldap_admin_password"
    partition_id           = "${var.ansible_vars["partition_id"]}"
    import_users_ldif      = "${var.ansible_vars["import_users_ldif"]}"
    sanitize_oid_ldif      = "${var.ansible_vars["sanitize_oid_ldif"]}"
    is_consumer            = "${var.ansible_vars["is_consumer"]}"
    provider_host          = "${var.ansible_vars["provider_host"]}"
  }
}
