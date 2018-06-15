module "ssh_key" {
  source   = "../modules/keys/ssh_key"
  keyname  = "${local.environment_name}"
  rsa_bits = "4096"
}
