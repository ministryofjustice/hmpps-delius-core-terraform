locals {
  legacy_to_mp = {
    "delius-mis-dev"  = "dev"
    "delius-test"     = "test"
    "delius-stage"    = "preprod"
    "delius-pre-prod" = "preprod"
  }
}


resource "aws_route53_record" "migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "delius-db-2"
  type    = "A"
  ttl     = "300"
  records = ["delius-db-2.${local.legacy_to_mp[var.environment_name]}.probation.justice.gov.uk"]
}

resource "aws_route53_record" "migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "delius-db-2"
  type    = "A"
  ttl     = "300"
  records = ["delius-db-2.${local.legacy_to_mp[var.environment_name]}.probation.justice.gov.uk"]
}
