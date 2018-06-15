output "kms_arn" {
  value = "${module.kms_key_master.kms_arn}"
}

output "kms_key_id" {
  value = "${module.kms_key_master.key_id}"
}

output "ssh_public_key" {
  value = "${module.ssh_key.public_key_openssh}"
}

output "ssh_private_key_pem" {
  sensitive = true
  value     = "${module.ssh_key.private_key_pem}"
}
