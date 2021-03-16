resource "aws_cloudwatch_log_group" "log_group" {
  # If a single container definition is provided with no log configuration, auto-create a log group
  count             = length(var.container_definitions) == 1 && ! contains(keys(var.container_definitions[0]), "logConfiguration") ? 1 : 0
  name              = "${var.environment_name}/${var.service_name}"
  retention_in_days = var.log_retention_in_days
  tags              = merge(var.tags, { Name = "${var.environment_name}/${var.service_name}" })
}
