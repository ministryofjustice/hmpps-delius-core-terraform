#TODO: ASG for managed should nightly cycle boxes

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.${var.tier_name}.sh")}"

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

    cldwatch_log_group            = "${var.ansible_vars["cldwatch_log_group"]}"

    s3_dependencies_bucket        = "${var.ansible_vars["s3_dependencies_bucket"]}"

    domain_name                   = "${var.ansible_vars["domain_name"]}"
    jvm_mem_args                  = "${var.ansible_vars["jvm_mem_args"]}"
    server_name                   = "${var.ansible_vars["server_name"]}"
    server_params                 = "${var.ansible_vars["server_params"]}"
    weblogic_admin_username       = "${var.ansible_vars["weblogic_admin_username"]}"
    server_listen_address         = "${var.ansible_vars["server_listen_address"]}"
    server_listen_port            = "${var.ansible_vars["server_listen_port"]}"

    setup_datasources             = "${var.ansible_vars["setup_datasources"]}"
    database_url                  = "${var.ansible_vars["database_url"]}"

    alfresco_host                 = "${var.ansible_vars["alfresco_host"]}"
    alfresco_port                 = "${var.ansible_vars["alfresco_port"]}"
    alfresco_office_host          = "${var.ansible_vars["alfresco_office_host"]}"
    alfresco_office_port          = "${var.ansible_vars["alfresco_office_port"]}"

    spg_host                      = "${var.ansible_vars["spg_host"]}"

    ldap_host                     = "${var.ansible_vars["ldap_host"]}"
    ldap_port                     = "${var.ansible_vars["ldap_port"]}"
    ldap_principal                = "${var.ansible_vars["ldap_principal"]}"
    partition_id                  = "${var.ansible_vars["partition_id"]}"

    ndelius_version               = "${var.ndelius_version}"
    ndelius_display_name          = "${var.ansible_vars["ndelius_display_name"]}"
    ndelius_training_mode         = "${var.ansible_vars["ndelius_training_mode"]}"
    ndelius_log_level             = "${var.ansible_vars["ndelius_log_level"]}"
    ndelius_analytics_tag         = "${var.ansible_vars["ndelius_analytics_tag"]}"
    activemq_data_folder          = "${var.ansible_vars["activemq_data_folder"]}"

    newtech_search_url            = "${var.ansible_vars["newtech_search_url"]}"
    newtech_pdfgenerator_url      = "${var.ansible_vars["newtech_pdfgenerator_url"]}"
    usermanagement_url            = "${var.ansible_vars["usermanagement_url"]}"
    nomis_url                     = "${var.ansible_vars["nomis_url"]}"
  }
}
