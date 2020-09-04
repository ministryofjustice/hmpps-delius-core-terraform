# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html
# https://docs.aws.amazon.com/batch/latest/userguide/batch_cwe_events.html

resource "aws_cloudwatch_event_rule" "dss_failure_event_rule" {
  name        = "${var.environment_name}-dss-batch-job-failure"
  description = "${var.environment_name}-dss-batch-job-failure"

  event_pattern = "${data.template_file.dss_failure_event_rule_template.rendered}" 
#   event_pattern = <<EOF
# {
#   "detail-type": [
#     "Batch Job State Change"
#   ],
#   "source": [
#     "aws.batch"
#   ],
#   "detail": {
#     "jobQueue": "arn:aws:batch:eu-west-2:050243167760:job-queue/delius-prod-ndelius-queue",
#     "status": [
#       "FAILED"
#     ]
#   }
# }   
# EOF
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = "${aws_cloudwatch_event_rule.dss_failure_event_rule.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.alarm_notification.arn}"
}


data "template_file" "dss_failure_event_rule_template" {
  template = "${file("./templates/cloudwatch/dss_failure_event_rule.tpl")}"

  vars {
    queue_arn = "${data.terraform_remote_state.batch.job_queue_arn}"
    # job_queue_arn = "arn:aws:batch:eu-west-2:050243167760:job-queue/delius-prod-ndelius-queue"
  }
}