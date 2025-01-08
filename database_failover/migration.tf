locals {
  legacy_to_mp_env = {
    "delius-mis-dev"  = "dev"
    "delius-test"     = "test"
    "delius-stage"    = "stage"
    "delius-pre-prod" = "preprod"
  }
  legacy_to_mp_vpc = {
    "delius-mis-dev"  = "development"
    "delius-test"     = "test"
    "delius-stage"    = "preproduction"
    "delius-pre-prod" = "preproduction"
  }
}


resource "aws_route53_record" "db1_migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "delius-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-core-${local.legacy_to_mp_env[var.environment_name]}-db-1.delius-core.${local.legacy_to_mp_env[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "db1_migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "delius-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-core-${local.legacy_to_mp_env[var.environment_name]}-db-1.delius-core.hmpps-${local.legacy_to_mp_env[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}
