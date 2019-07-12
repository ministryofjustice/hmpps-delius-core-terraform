locals {
  app_name        = "umt"
  image_url       = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ndelius-um"
  image_version   = "${var.umt_config["version"]}"
  config_location = "/app/config"
  host_config_location = "/${local.app_name}/config"
}