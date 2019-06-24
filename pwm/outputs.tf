output "private_fqdn_pwm" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn_pwm" {
  value = "${aws_route53_record.public_dns.fqdn}"
}