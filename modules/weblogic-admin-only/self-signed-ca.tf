module "ca_key" {
  source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//tls//tls_private_key"
  algorithm = "RSA"
  rsa_bits  = "4096"
}

module "ca_cert" {
  source                = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//tls//tls_self_signed_cert"
  key_algorithm         = "RSA"
  private_key_pem       = "${module.ca_key.private_key}"
  subject               = [{
    common_name  = "ca.${var.private_domain}"
    organization = "${var.environment_identifier}"
  }]
  validity_period_hours = "8544"
  early_renewal_hours   = "672"
  is_ca_certificate     = "true"
  allowed_uses          = [
    "cert_signing",
    "crl_signing",
  ]
}

module "create_parameter_ca_cert" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ssm//parameter_store_file"
  parameter_name = "${var.environment_identifier}-self-signed-ca-crt"
  description    = "${var.environment_identifier}-self-signed-ca-crt"
  type           = "String"
  value          = "${module.ca_cert.cert_pem}"
  tags           = "${var.tags}"
}
