locals {
  lb_id = replace(var.loadbalancer_arn, "/.+:loadbalancer.{1}/", "")
  tg_id = replace(var.targetgroup_arn, "/.+:targetgroup.{1}/", "targetgroup/")
}

