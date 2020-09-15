locals {
  name       = "${var.short_environment_name}-${var.service_name}"
  short_env  = format("%.12s", var.short_environment_name)               # Because the short_environment_name isn't that short...
  short_name = format("%.28s", "${local.short_env}-${var.service_name}") # For resources that have a limit on name length (eg. target group)
}

