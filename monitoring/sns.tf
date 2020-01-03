resource "aws_sns_topic" "alarm_notification" {
  name = "${var.environment_name}-delius-core-alarm-notification"
}

resource "aws_sns_topic_subscription" "alarm_subscription" {
  protocol  = "lambda"
  topic_arn = "${aws_sns_topic.alarm_notification.arn}"
  endpoint  = "${aws_lambda_function.notify_slack.arn}"
}
