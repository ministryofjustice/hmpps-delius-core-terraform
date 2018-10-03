#TODO: ASG for managed should nightly cycle boxes

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
    env_identifier          = "${var.environment_identifier}"
    short_env_identifier    = "${var.short_environment_identifier}"
    region                  = "${var.region}"
    app_name                = "${var.tier_name}"
    route53_sub_domain      = "${var.environment_name}"
    private_domain          = "${var.private_domain}"
    account_id              = "${var.vpc_account_id}"
  }
}
