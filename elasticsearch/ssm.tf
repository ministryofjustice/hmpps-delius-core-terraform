resource "random_password" "master_password" {
  length = 32
  # Requirements enforced by Elasticsearch:
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!%()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "username" {
  name  = "/${var.environment_name}/${var.project_name}/elasticsearch/${local.contact_search_name}/username"
  value = "master"
  type  = "String"
}

resource "aws_ssm_parameter" "password" {
  name  = "/${var.environment_name}/${var.project_name}/elasticsearch/${local.contact_search_name}/password"
  value = random_password.master_password.result
  type  = "SecureString"
}

resource "aws_ssm_parameter" "endpoint" {
  name  = "/${var.environment_name}/${var.project_name}/elasticsearch/${local.contact_search_name}/endpoint"
  value = aws_elasticsearch_domain.contact_search.endpoint
  type  = "String"
}
