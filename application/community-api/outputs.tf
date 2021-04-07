output "url" {
  value = "https://${aws_route53_record.alb.fqdn}"
}

output "documentation_url" {
  value = "https://${aws_route53_record.public_alb.fqdn}"
}

output "legacy_url" {
  value = "https://${aws_route53_record.legacy_secure_url.fqdn}"
}

output "service_discovery_url" {
  value = "${local.app_name}.${data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["domain_name"]}"
}

output "service" {
  value = module.ecs.service
}

