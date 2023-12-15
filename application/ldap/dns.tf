# Create record in private hosted zone

# migration parameter
resource "aws_ssm_parameter" "mp_ldap" {
  count = contains(local.migrated_envs, var.environment_name) ? 1 : 0
  name = "/migration/mp_ldap"
  type = "String"
  value = "initial value"
  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "mp_ldap" {
    count = contains(local.migrated_envs, var.environment_name) ? 0 : 1
  name = aws_ssm_parameter.mp_ldap[0].name
}

resource "aws_route53_record" "ldap_elb_private" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "ldap"
  type    = "CNAME"
  ttl     = "300"
  records = contains(local.migrated_envs, var.environment_name) ? [data.aws_ssm_parameter.mp_ldap[0].value] : [aws_elb.lb[0].dns_name]
}

# Create record in public hosted zone, i.e. useful for name resolution between accounts connected through TGW
resource "aws_route53_record" "ldap_elb_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "ldap"
  type    = "CNAME"
  ttl     = "300"
  records = contains(local.migrated_envs, var.environment_name) ? [data.aws_ssm_parameter.mp_ldap[0].value] : [aws_elb.lb[0].dns_name]
}

