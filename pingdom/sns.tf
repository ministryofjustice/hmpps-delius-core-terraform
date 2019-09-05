resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  protocol  = "lambda"
  topic_arn = "${data.terraform_remote_state.pingdom_sns.pingdom_ips_sns_topic_arn}"
  endpoint  = "${aws_lambda_function.update_security_group_function.arn}"
}