# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
# https://docs.aws.amazon.com/batch/latest/userguide/batch_cwe_events.html

resource "aws_cloudwatch_event_rule" "dss_failure_event_rule" {
  name        = "${var.environment_name}-dss-batch-job-failure"
  description = "${var.environment_name}-dss-batch-job-failure"

  event_pattern = jsonencode({
    source = ["aws.batch"]
    detail = {
      jobQueue = [module.dss_batch_environment.job_queue_arn]
    }
  })
}

resource "aws_cloudwatch_event_target" "notify_slack_via_sns" {
  rule = aws_cloudwatch_event_rule.dss_failure_event_rule.name
  arn  = data.terraform_remote_state.alerts.outputs.aws_sns_topic_batch_status_notification_arn
}
