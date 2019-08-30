output "private_fqdn_pwm" {
  value = "${aws_route53_record.internal_lb_private_dns.fqdn}"
}

output "public_fqdn_pwm" {
  value = "${aws_route53_record.public_dns.fqdn}"
}