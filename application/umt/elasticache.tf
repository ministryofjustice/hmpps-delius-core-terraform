resource "aws_elasticache_subnet_group" "subnet_group" {
  name = "${var.environment_name}-${local.app_name}-subnet-group"
  subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name   = "${var.environment_name}-${local.app_name}-redis-pg"
  family = "redis5.0"

  # We need to turn on 'notify-keyspace-events' to support Spring Redis session expiration.
  # See https://github.com/spring-projects/spring-session/issues/124
  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }
}

resource "aws_elasticache_replication_group" "token_store_replication_group" {
  replication_group_id          = "${var.environment_name}-${local.app_name}-rg"
  replication_group_description = "${var.environment_name}-${local.app_name} - Token store replication group"
  security_group_ids            = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_umt_tokenstore_id]
  subnet_group_name             = aws_elasticache_subnet_group.subnet_group.name
  engine                        = "redis"
  engine_version                = "5.0.6"
  parameter_group_name          = aws_elasticache_parameter_group.redis_parameter_group.name
  port                          = 6379
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  apply_immediately             = var.environment_name != "delius-prod"
  tags                          = var.tags
  node_type                     = local.app_config["redis_node_type"]
  cluster_mode {
    num_node_groups         = local.app_config["redis_node_groups"]
    replicas_per_node_group = local.app_config["redis_replicas_per_node_group"]
  }
}

resource "aws_route53_record" "token_store_private_dns" {
  zone_id = data.aws_route53_zone.private.id
  name    = "${local.app_name}-token-store"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_replication_group.token_store_replication_group.configuration_endpoint_address]
}

