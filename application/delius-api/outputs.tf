output "url" {
  value = "https://${aws_route53_record.alb.fqdn}"
}

output "public_url" {
  value = "https://${aws_route53_record.public_alb.fqdn}"
}

output "service_discovery_url" {
  value = "${local.app_name}.${data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["domain_name"]}"
}

output "service" {
  value = module.ecs.service
}

output "alb" {
  value = {
    "name"       = aws_lb.alb.name
    "arn"        = aws_lb.alb.arn
    "arn_suffix" = aws_lb.alb.arn_suffix
  }
}