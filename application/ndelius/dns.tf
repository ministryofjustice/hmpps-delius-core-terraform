resource "aws_route53_record" "private_dns" {
  zone_id = data.aws_route53_zone.private.id
  name    = "ndelius"
  type    = "CNAME"
  ttl     = "300"
  records = [module.external_nlb.dns_name]
}

resource "aws_route53_record" "public_dns" {
  # NOTE:
  # This is only in place to support transition from the old public zone (dsd.io) to the strategic public zone (gov.uk).
  # It allows us to configure which zone to use for public-facing services (eg. NDelius, PWM) on a per-environment
  # basis. Currently only Prod and Pre-Prod should use the old public zone, once they are transitioned over we should
  # remove this. Additionally, there are a few services that have DNS records in the public zone that should be moved
  # over into the private zone before we complete the transition eg. delius-db-1, management.
  # (see weblogic-ndelius.tf)
  zone_id = var.delius_core_public_zone == "strategic" ? data.terraform_remote_state.vpc.outputs.strategic_public_zone_id : data.terraform_remote_state.vpc.outputs.public_zone_id

  name = "ndelius"
  type = "CNAME"
  ttl  = "300"
  records = [module.external_nlb.dns_name]
}

