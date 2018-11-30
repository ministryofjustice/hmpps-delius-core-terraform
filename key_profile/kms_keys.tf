module "kms_key_app" {
  source   = "../modules/keys/encryption_key"
  key_name = "${var.environment_name}-app"
  tags     = "${merge(var.tags, map("Name", "${var.environment_name}-app"))}"
}

output "kms_arn_app" {
  value = "${module.kms_key_app.kms_arn}"
}

output "kms_key_id_app" {
  value = "${module.kms_key_app.key_id}"
}
