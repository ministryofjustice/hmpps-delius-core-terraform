locals {
  legacy_to_mp = {
    "delius-mis-dev"  = "dev"
    "delius-test"     = "test"
    "delius-stage"    = "stage"
    "delius-pre-prod" = "preprod"
  }
}


resource "aws_route53_record" "db1_migration_internal" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "delius-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-core-${local.legacy_to_mp[var.environment_name]}-db-1.modernisation-platform.internal"]
}

resource "aws_route53_record" "db1_migration_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "delius-db-1"
  type    = "CNAME"
  ttl     = "300"
  records = ["delius-core-${local.legacy_to_mp[var.environment_name]}-db-1.modernisation-platform.internal"]
}

