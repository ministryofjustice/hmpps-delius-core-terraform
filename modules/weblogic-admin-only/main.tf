#TODO: ASG for managed should nightly cycle boxes

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.${var.tier_name}.sh")}"

  vars {
    env_identifier                = "${var.environment_identifier}"
    short_env_identifier          = "${var.short_environment_identifier}"
    region                        = "${var.region}"
    app_name                      = "${var.tier_name}"
    route53_sub_domain            = "${var.environment_name}"
    private_domain                = "${var.private_domain}"
    account_id                    = "${var.vpc_account_id}"
    bastion_inventory             = "${var.bastion_inventory}"
    app_bootstrap_name            = "${var.app_bootstrap_name}"
    app_bootstrap_src             = "${var.app_bootstrap_src}"
    app_bootstrap_version         = "${var.app_bootstrap_version}"
    app_bootstrap_initial_role    = "${var.app_bootstrap_initial_role}"
    app_bootstrap_secondary_role  = "${var.app_bootstrap_secondary_role}"
    app_bootstrap_tertiary_role   = "${var.app_bootstrap_tertiary_role}"
    ndelius_version               = "${var.ndelius_version}"
  }
}
