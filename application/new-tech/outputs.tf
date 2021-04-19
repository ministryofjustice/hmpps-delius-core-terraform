output "service_discovery_url" {
  value = "${local.app_name}.${data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["domain_name"]}"
}

output "service" {
  value = module.ecs.service
}

