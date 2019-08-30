resource "aws_route53_record" "private_dns" {
  zone_id = "${data.aws_route53_zone.private.id}"
  name    = "interface"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.external_nlb.dns_name}"]
}

resource "aws_route53_record" "public_dns" {
  zone_id = "${data.aws_route53_zone.public.id}"
  name    = "interface"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.external_nlb.dns_name}"]
}

output "private_fqdn_interface_wls_external" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn_interface_wls_external" {
  value = "${aws_route53_record.public_dns.fqdn}"
}