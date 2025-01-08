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


resource "aws_route53_record" "db2_migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "delius-db-2"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-core-${local.legacy_to_mp_env[var.environment_name]}-db-2.delius-core.${local.legacy_to_mp_env[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "db2_migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "delius-db-2"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-core-${local.legacy_to_mp_env[var.environment_name]}-db-2.delius-core.${local.legacy_to_mp_env[var.environment_name]}.modernisation-platform.service.justice.gov.uk"]
}
