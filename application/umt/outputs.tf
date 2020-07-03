output "service" {
  value = "${module.ecs.service}"
}

output "token_store" {
  value = {
    host                 = "${aws_route53_record.token_store_private_dns.fqdn}"
    port                 = "${aws_elasticache_replication_group.token_store_replication_group.port}"
    replication_group_id = "${aws_elasticache_replication_group.token_store_replication_group.replication_group_id}"
  }
}