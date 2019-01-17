locals {
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]

  dns_names = ["*.${var.private_domain}"]

  subject = {
    common_name  = "${var.private_domain}"
    organization = "${var.environment_identifier}"
  }
}

module "server_key" {
  source    = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//tls//tls_private_key"
  algorithm = "RSA"
  rsa_bits  = "2048"
}

module "server_csr" {
  source          = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//tls//tls_cert_request"
  key_algorithm   = "RSA"
  private_key_pem = "${module.server_key.private_key}"
  subject         = ["${local.subject}"]
  dns_names       = ["${local.dns_names}"]
}

module "server_cert" {
  source             = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//tls//tls_locally_signed_cert"
  cert_request_pem   = "${module.server_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${module.ca_key.private_key}"
  ca_cert_pem        = "${module.ca_cert.cert_pem}"

  validity_period_hours = "2160"
  early_renewal_hours   = "336"

  allowed_uses = ["${local.allowed_uses}"]
}

module "iam_server_certificate" {
  source            = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//iam_certificate"
  name_prefix       = "${var.private_domain}-cert"
  certificate_body  = "${module.server_cert.cert_pem}"
  private_key       = "${module.server_key.private_key}"
  certificate_chain = "${module.ca_cert.cert_pem}"
  path              = "/${var.environment_identifier}/"
}

module "create_parameter_cert" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ssm//parameter_store_file"
  parameter_name = "${var.environment_identifier}-self-signed-crt"
  description    = "${var.environment_identifier}-self-signed-crt"
  type           = "String"
  value          = "${module.server_cert.cert_pem}"
  tags           = "${var.tags}"
}

module "create_parameter_key" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//ssm//parameter_store_file"
  parameter_name = "${var.environment_identifier}-self-signed-private-key"
  description    = "${var.environment_identifier}-self-signed-private-key"
  type           = "SecureString"
  value          = "${module.server_key.private_key}"
  tags           = "${var.tags}"
}
