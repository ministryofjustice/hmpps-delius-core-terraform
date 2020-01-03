locals {
  ndelius_alb_id          = "${replace(data.terraform_remote_state.ndelius.alb["id"], "/.+:loadbalancer.{1}/", "")}"
  lambda_name             = "${var.environment_name}-notify-delius-core-slack-channel"
  quiet_period_start_hour = "0"
  quiet_period_end_hour   = "3"
}