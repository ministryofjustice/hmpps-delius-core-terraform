terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "pingdom" {
  user          = "${var.pingdom_user}"
  password      = "${var.pingdom_password}"
  api_key       = "${var.pingdom_api_key}"
  account_email = "${var.pingdom_account_email}"
}