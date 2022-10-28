resource "aws_ssm_parameter" "initialise_empty_parameters" {
  for_each = toset([
    "/${var.environment_name}/${var.project_name}/moj-cloud-platform/hmpps-domain-events/topic-arn",
    "/${var.environment_name}/${var.project_name}/moj-cloud-platform/hmpps-domain-events/aws-access-key-id",
    "/${var.environment_name}/${var.project_name}/moj-cloud-platform/hmpps-domain-events/aws-secret-access-key",
  ])
  name  = each.value
  value = "none" # Manually added per-environment in AWS Parameter Store
  type  = "SecureString"
  lifecycle {
    ignore_changes = [value]
  }
}