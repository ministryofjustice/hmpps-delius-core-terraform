resource "tls_cert_request" "database" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name         = "${var.environment_name}.oracle-crt"
    organization        = "Ministry of Justice"
    country             = "GB"
    organizational_unit = "HMPPS"
  }
}

############################################
# SIGN CERT
############################################
# cert
resource "tls_locally_signed_cert" "database" {
   ca_cert_pem           = tls_self_signed_cert.ca_cert.cert_pem
   ca_private_key_pem    = tls_private_key.ca_key.private_key_pem
   cert_request_pem      = tls_cert_request.database.cert_request_pem
   validity_period_hours = var.self_signed_ca_validity_period_hours
   
   allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "key_agreement",
    "any_extended"
   ]
}

############################################
# ADD TO SSM
############################################
resource "aws_ssm_parameter" "database" {
  name        = "tf-${var.region}-${var.environment_name}-oracle-self-signed-crt"
  description = "tf-${var.region}-${var.environment_name}-oracle-self-signed-crt"
  type        = "String"
  value       = tls_locally_signed_cert.database.cert_pem

  tags        = local.tags
}