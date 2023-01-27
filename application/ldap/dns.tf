# Create record in private hosted zone
resource "aws_route53_record" "ldap_elb_private" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "ldap"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elb.lb.dns_name]
}

# Create record in public hosted zone, i.e. useful for name resolution between accounts connected through TGW
resource "aws_route53_record" "ldap_elb_public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
  name    = "ldap"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elb.lb.dns_name]
}

