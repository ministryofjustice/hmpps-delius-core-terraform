resource "tls_private_key" "deploy" {
  algorithm = "RSA"
  rsa_bits  = "${var.rsa_bits}"
}

resource "aws_key_pair" "environment" {
  key_name   = "${var.keyname}"
  public_key = "${tls_private_key.deploy.public_key_openssh}"
}
