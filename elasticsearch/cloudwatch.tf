resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/${var.environment_name}/contact-search/elasticsearch-logs"
  retention_in_days = lookup(local.contact_search_config, "log_retention_days", 365)
  tags              = merge(var.tags, { Name = "/${var.environment_name}/contact-search/elasticsearch-logs" })
}

data "aws_iam_policy_document" "log_policy_document" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream"
    ]
    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "log_policy" {
  policy_name     = "${var.environment_name}-contact-search-write-logs"
  policy_document = data.aws_iam_policy_document.log_policy_document.json
}


# CloudWatch alarms as recommended by https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/cloudwatch-alarms.html
resource "aws_cloudwatch_metric_alarm" "cluster_status_red" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-cluster-status--fatal"
  alarm_description   = "The `${local.contact_search_name}` Elasticsearch cluster status is red. At least one primary shard and its replicas are not allocated to a node. See <https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-red-cluster-status|Red cluster status>."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "ClusterStatus.red"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 60
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_yellow" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-cluster-status--warn"
  alarm_description   = "The `${local.contact_search_name}` Elasticsearch cluster status is yellow. At least one replica shard is not allocated to a node. See <https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-yellow-cluster-status|Yellow cluster status>."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "ClusterStatus.yellow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 60
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-free-storage--warn"
  alarm_description   = "A node in the `${local.contact_search_name}` Elasticsearch cluster is down to ${ceil(local.contact_search_config["volume_size"] * 0.25)} GiB of free storage space. See <https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-watermark|Lack of available storage space>."
  namespace           = "AWS/ES"
  statistic           = "Minimum"
  metric_name         = "FreeStorageSpace"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = ceil(local.contact_search_config["volume_size"] * 1024 * 0.25)
  evaluation_periods  = 1
  period              = 60
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "writes_blocked" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-writes-blocked--fatal"
  alarm_description   = "The `${local.contact_search_name}` Elasticsearch cluster is blocking write requests. See <https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-handling-errors.html#troubleshooting-cluster-block|ClusterBlockException>."
  namespace           = "AWS/ES"
  statistic           = "Minimum"
  metric_name         = "ClusterIndexWritesBlocked"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 300 # 5 minutes
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "unreachable_nodes" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-unreachable-nodes--warn"
  alarm_description   = "At least one node in the `${local.contact_search_name}` Elasticsearch cluster has been unreachable for one day. See <https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-failed-cluster-nodes|Failed cluster nodes>."
  namespace           = "AWS/ES"
  statistic           = "Minimum"
  metric_name         = "Nodes"
  comparison_operator = "LessThanThreshold"
  threshold           = local.contact_search_config["instance_count"] + (local.contact_search_config["dedicated_master_enabled"] ? local.contact_search_config["dedicated_master_count"] : 0)
  evaluation_periods  = 1
  period              = 86400 # 1 day
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "snapshot_failure" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-snapshot-failure--warn"
  alarm_description   = "An automated snapshot of the `${local.contact_search_name}` Elasticsearch cluster failed. This failure is often the result of a red cluster health status. See <Red cluster status|https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/aes-handling-errors.html#aes-handling-errors-red-cluster-status>."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "AutomatedSnapshotFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 60
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_usage" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-cpu-usage--warn"
  alarm_description   = "CPU utilization exceeded 80% for the `${local.contact_search_name}` Elasticsearch cluster. Consider using larger instance types or adding instances."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 80
  evaluation_periods  = 3
  period              = 900
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_pressure" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-memory-pressure--warn"
  alarm_description   = "JVM memory pressure exceeded 80% for the `${local.contact_search_name}` Elasticsearch cluster. The cluster could encounter out of memory errors if usage increases. Consider scaling vertically."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "JVMMemoryPressure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 80
  evaluation_periods  = 3
  period              = 300
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "master_cpu_usage" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-master-cpu-usage--warn"
  alarm_description   = "CPU utilization exceeded 50% for the `${local.contact_search_name}` Elasticsearch cluster dedicated master nodes."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "MasterCPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 50
  evaluation_periods  = 3
  period              = 900
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "master_memory_pressure" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-master-memory-pressure--warn"
  alarm_description   = "JVM memory pressure exceeded 80% for the `${local.contact_search_name}` Elasticsearch cluster dedicated master nodes."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "MasterJVMMemoryPressure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 80
  evaluation_periods  = 1
  period              = 900
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_key_error" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-kms-key-error--critical"
  alarm_description   = "The KMS encryption key that is used to encrypt data at rest in the `${local.contact_search_name}` Elasticsearch cluster is disabled. Re-enable it to restore normal operations."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "KMSKeyError"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 60
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

resource "aws_cloudwatch_metric_alarm" "kms_key_inaccessible" {
  alarm_name          = "${var.environment_name}-${local.contact_search_name}-kms-key-inaccessible--fatal"
  alarm_description   = "The KMS encryption key that is used to encrypt data at rest in the `${local.contact_search_name}` Elasticsearch cluster has been deleted or has revoked its grants to Amazon ES. You can't recover domains that are in this state, but if you have a manual snapshot, you can use it to migrate to a new domain."
  namespace           = "AWS/ES"
  statistic           = "Maximum"
  metric_name         = "KMSKeyInaccessible"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 60
  alarm_actions       = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions          = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  dimensions = {
    DomainName = "${var.short_environment_name}-${local.contact_search_short_name}"
    ClientId   = data.aws_caller_identity.current.account_id
  }
}
