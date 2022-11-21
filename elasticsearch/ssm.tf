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

resource "random_string" "password_prefix" {
  length    = 4
  upper     = true
  min_upper = 1
  lower     = true
  min_lower = 1
  numeric   = false
  special   = false
}

# random strings for Password policy
resource "random_string" "password_remainder" {
  length           = 50
  special          = true
  override_special = "!$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "database_username" {
  name  = "/${var.environment_name}/${var.project_name}/elasticsearch/${local.contact_search_name}/database-username"
  value = "contact_search_pool"
  type  = "String"
}

resource "aws_ssm_parameter" "database_password" {
  name  = "/${var.environment_name}/${var.project_name}/elasticsearch/${local.contact_search_name}/database-password"
  value = "${random_string.password_prefix.result}${substr(bcrypt(random_string.password_remainder.result), 4, 11)}"
  type  = "SecureString"
}