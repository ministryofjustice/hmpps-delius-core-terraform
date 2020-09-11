# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
# https://docs.aws.amazon.com/batch/latest/userguide/batch_cwe_events.html

resource "aws_cloudwatch_event_rule" "dss_failure_event_rule" {
  name        = "${var.environment_name}-dss-batch-job-failure"
  description = "${var.environment_name}-dss-batch-job-failure"

  event_pattern = "${data.template_file.dss_failure_event_rule_template.rendered}" 
}

resource "aws_cloudwatch_event_target" "sns" {
  rule     = "${aws_cloudwatch_event_rule.dss_failure_event_rule.name}"
  arn      = "${aws_sns_topic.batch_notification.arn}"
}


data "template_file" "dss_failure_event_rule_template" {
  template = "${file("./templates/cloudwatch/dss_failure_event_rule.tpl")}"

  vars {
    job_queue_arn = "${data.terraform_remote_state.batch.job_queue_arn}"
  }
}
