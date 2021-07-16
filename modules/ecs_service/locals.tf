locals {
  name           = "${var.short_environment_name}-${var.service_name}"
  short_env      = format("%.12s", var.short_environment_name)               # Because the short_environment_name isn't that short...
  short_name     = format("%.28s", "${local.short_env}-${var.service_name}") # For resources that have a limit on name length (eg. target group)
  secrets_format = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter%s"

  # If a single container definition is provided with no log configuration, auto-create a log group:
  create_log_group = length(var.container_definitions) == 1 && ! contains(keys(var.container_definitions[0]), "logConfiguration")

  # Get directory name for each additional log file
  additional_log_directories = { for name, path in var.additional_log_files : dirname(path) => name }
}

