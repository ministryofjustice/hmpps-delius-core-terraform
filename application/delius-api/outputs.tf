output "public_fqdn" {
  value = aws_route53_record.public_dns.fqdn
}

output "url" {
  value = "https://${aws_route53_record.public_dns.fqdn}"
}

output "service" {
  value = module.ecs.service
}

