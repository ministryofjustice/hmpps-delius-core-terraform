output "private_fqdn" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn" {
  value = "${aws_route53_record.public_dns.fqdn}"
}