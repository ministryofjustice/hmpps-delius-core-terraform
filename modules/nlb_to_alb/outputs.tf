output "dns_name" {
  value = var.enabled ? aws_lb.external_nlb[0].dns_name : null
}

