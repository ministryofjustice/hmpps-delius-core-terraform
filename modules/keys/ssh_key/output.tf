output "public_key_openssh" {
  value = "${tls_private_key.deploy.public_key_openssh}"
}

output "private_key_pem" {
  sensitive = true
  value     = "${tls_private_key.deploy.private_key_pem}"
}
