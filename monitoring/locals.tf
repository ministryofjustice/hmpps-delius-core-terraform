locals {
  ndelius_alb_id          = "${replace(data.terraform_remote_state.ndelius.alb["id"], "/.+:loadbalancer.{1}/", "")}"
  lambda_name_alarm       = "${var.environment_name}-notify-delius-core-slack-channel-alarm"
  lambda_name_batch       = "${var.environment_name}-notify-delius-core-slack-channel-batch"
  quiet_period_start_hour = "0"
  quiet_period_end_hour   = "3"
}