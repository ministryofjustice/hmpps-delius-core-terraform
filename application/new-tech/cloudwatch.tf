resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.environment_name}/${local.app_name}"
  retention_in_days = 365
  tags              = merge(var.tags, { Name = "${var.environment_name}/${local.app_name}" })
}

