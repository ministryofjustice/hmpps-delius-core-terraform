locals {
  app_name        = "community-api"
  short_name      = "comapi"
  app_config      = merge(var.default_community_api_config, var.community_api_config)
  secrets         = { for key, value in local.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }
  environment     = { for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }
  certificate_arn = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.legacy_cert.arn
  route53_zone_id = var.delius_core_public_zone == "strategic" ? data.terraform_remote_state.vpc.outputs.strategic_public_zone_id : data.terraform_remote_state.vpc.outputs.public_zone_id
}

