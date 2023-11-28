############################################
# CREATE TLS KEY
############################################
# CA KEY 
resource "tls_private_key" "ca_key" {
  algorithm = var.self_signed_ca_algorithm
  rsa_bits  = var.self_signed_ca_rsa_bits
}

############################################
# CREATE TLS CA CERT
############################################
# # CA CERT
resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem       = tls_private_key.ca_key.private_key_pem
  validity_period_hours = var.self_signed_ca_validity_period_hours
  early_renewal_hours   = var.self_signed_ca_early_renewal_hours
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  subject {
    common_name         = "${var.environment_name}.oracle-ca"
    organization        = "Ministry of Justice"
    country             = "GB"
    organizational_unit = "HMPPS"
  }

}

############################################
# ADD TO SSM
############################################
# Add to SSM
resource "aws_ssm_parameter" "ca_crt" {
  name        = "tf-${var.region}-${var.environment_name}-oracle-self-signed-ca-crt"
  description = "tf-${var.region}-${var.environment_name}-oracle-self-signed-ca-crt"
  type        = "String"
  value       = tls_self_signed_cert.ca_cert.cert_pem

  tags = merge(var.tags, map("Name", "tf-${var.region}-${var.environment_name}-oracle-self-signed-ca-crt"))
}

resource "aws_ssm_parameter" "private_key" {
  name        = "tf-${var.region}-${var.environment_name}-oracle-self-signed-private-key"
  description = "tf-${var.region}-${var.environment_name}-oracle-self-signed-private-key"
  type        = "SecureString"
  value       = tls_private_key.ca_key.private_key_pem

  tags= merge(var.tags, map("Name", "tf-${var.region}-${var.environment_name}-oracle-self-signed-ca-crt"))
}