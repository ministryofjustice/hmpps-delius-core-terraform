locals {
  ndelius_alb_id = replace(
    data.terraform_remote_state.ndelius.outputs.alb["id"],
    "/.+:loadbalancer.{1}/",
    "",
  )
  lambda_name_alarm = "${var.environment_name}-notify-delius-core-slack-channel-alarm"
  lambda_name_batch = "${var.environment_name}-notify-delius-core-slack-channel-batch"
}

