locals {
  name       = "${var.short_environment_name}-${var.service_name}"
  short_name = "${format("%.28s", local.name)}"                    # Truncated to a max of 28 chars, for resources that have a limit on name length (eg. target group)
}
