locals {
  app_name      = "usermanagement"
  image_url     = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ndelius-um"
  umt_config    = "${merge(var.default_umt_config, var.umt_config)}"
  ansible_vars  = "${merge(var.default_ansible_vars, var.ansible_vars)}"
}