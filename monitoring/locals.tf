locals {
  ndelius_alb_id = "${replace(data.terraform_remote_state.ndelius.alb["id"], "/.+:loadbalancer.{1}/", "")}"
}