output "public_url" {
  value = "https://${aws_route53_record.public_dns.fqdn}"
}

output "private_url" {
  value = "https://${aws_route53_record.private_dns.fqdn}"
}

output "legacy_url" {
  value = "https://${aws_route53_record.internal_alb_public.fqdn}"
}

output "service_discovery_url" {
  value = "${var.app_name}.${data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["domain_name"]}"
}

output "service" {
  value = module.ecs.service
}

output "lb_listener_arn" {
  value = aws_lb_listener.https_listener.arn
}

output "alb" {
  value = {
    "id"   = aws_lb.alb.id
    "arn"  = aws_lb.alb.arn
    "name" = aws_lb.alb.name
  }
}
