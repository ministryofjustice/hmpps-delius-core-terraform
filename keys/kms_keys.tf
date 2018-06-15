module "kms_key_master" {
  source   = "../modules/keys/encryption_key"
  key_name = "${local.environment_name}-master"
  tags     = "${var.tags}"
}
