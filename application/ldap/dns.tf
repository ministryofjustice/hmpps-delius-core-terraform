resource "aws_route53_record" "ldap_elb_private" {
  zone_id = data.terraform_remote_state.vpc.outputs.private_zone_id
  name    = "ldap"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elb.lb.dns_name]
}

