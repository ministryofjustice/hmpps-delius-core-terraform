output "private_fqdn_pwm" {
  value = aws_route53_record.internal_lb_private_dns.fqdn
}

output "public_fqdn_pwm" {
  value = aws_route53_record.public_dns.fqdn
}

output "url" {
  value = "https://${aws_route53_record.public_dns.fqdn}/public/forgottenpassword"
}

output "alb" {
  value = {
    "name"       = aws_lb.alb.name
    "arn"        = aws_lb.alb.arn
    "arn_suffix" = aws_lb.alb.arn_suffix
  }
}

output "target_group" {
  value = module.service.primary_target_group
}
