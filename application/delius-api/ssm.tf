resource "aws_ssm_parameter" "image_version" {
  name        = "/versions/delius-core/ecs/delius-api/${var.environment_name}"
  value       = "latest"
  type        = "String"
  description = "Delius-API image version. Managed by CircleCI."
  lifecycle {
    ignore_changes = [value]
  }
}
