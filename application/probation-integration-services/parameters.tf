resource "aws_ssm_parameter" "jdbc_url_parameter" {
  name  = "/${var.environment_name}/${var.project_name}/probation-integration/delius-database/jdbc-url"
  value = data.terraform_remote_state.database.outputs.jdbc_failover_url
  type  = "SecureString"
}

resource "aws_ssm_parameter" "jdbc_standby_url_parameter" {
  name  = "/${var.environment_name}/${var.project_name}/probation-integration/delius-database/jdbc-standby-url"
  value = data.terraform_remote_state.database.outputs.jdbc_standby_url
  type  = "SecureString"
}

# IAM policy to grant access to SSM parameters in the probation-integration namespace
data "aws_iam_policy_document" "ssm_access" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = ["arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/probation-integration/*"]
  }
}

resource "aws_iam_policy" "access_ssm_parameters" {
  name   = "${var.environment_name}-probation-integration-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_access.json
}
