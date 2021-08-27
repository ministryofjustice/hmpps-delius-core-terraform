resource "random_shuffle" "subnets" {
  # If there are fewer than 3 instances configured, then select a subset of AZs at random
  result_count = min(local.contact_search_config["instance_count"], 3)
  input = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
  ]
}

resource "aws_elasticsearch_domain" "contact_search" {
  domain_name           = "${var.short_environment_name}-${local.contact_search_short_name}"
  elasticsearch_version = "7.10"
  tags                  = merge(var.tags, { Name = "${var.short_environment_name}-${local.contact_search_short_name}" })

  vpc_options {
    subnet_ids         = random_shuffle.subnets.result
    security_group_ids = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_contact_search_domain_id]
  }

  cluster_config {
    instance_count           = local.contact_search_config["instance_count"]
    instance_type            = local.contact_search_config["instance_type"]
    dedicated_master_enabled = local.contact_search_config["dedicated_master_enabled"]
    dedicated_master_count   = lookup(local.contact_search_config, "dedicated_master_count", null)
    dedicated_master_type    = lookup(local.contact_search_config, "dedicated_master_type", null)

    # Disable multi-az if instance_count is set to 1
    zone_awareness_enabled = local.contact_search_config["instance_count"] > 1
    dynamic "zone_awareness_config" {
      for_each = local.contact_search_config["instance_count"] > 1 ? ["1"] : []
      content {
        availability_zone_count = min(local.contact_search_config["instance_count"], 3)
      }
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = local.contact_search_config["volume_type"]
    volume_size = local.contact_search_config["volume_size"]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.log_group.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = aws_ssm_parameter.username.value
      master_user_password = aws_ssm_parameter.password.value
    }
  }

  encrypt_at_rest { enabled = true }
  node_to_node_encryption { enabled = true }

  snapshot_options {
    automated_snapshot_start_hour = local.contact_search_config["automated_snapshot_start_hour"]
  }

  # Using VPC mode, so access is restricted via Security Groups rather than IAM
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "es:*"
      Effect = "Allow"
      Principal = {
        AWS = "*"
      }
      Resource = "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.short_environment_name}-${local.contact_search_short_name}/*"
    }]
  })
}
