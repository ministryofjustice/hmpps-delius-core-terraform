output "api_service" {
  value = module.api.service
}

output "ui_service" {
  value = module.ui.service
}

output "primary_db" {
  value = {
    id       = aws_db_instance.primary.id
    name     = aws_db_instance.primary.name
    address  = aws_db_instance.primary.address
    port     = aws_db_instance.primary.port
    endpoint = aws_db_instance.primary.endpoint
  }
}

output "kms_key_id" {
    value    = module.kms_custom_policy.kms_key_id
}
