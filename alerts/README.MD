# Alerts

Common infrastructure used for sending Slack alerts from various parts of the `hmpps-delius-core-terraform` repository.

## Resources
* [lambda.tf](lambda.tf) - Lambda functions for formatting and sending Slack messages
* [sns.tf](sns.tf) - SNS topics for receiving notifications, with subscriptions for the Lambda handlers

## Usage
The topic ARN is outputted in the Terraform state at `aws_sns_topic_alarm_notification_arn`.
To create a CloudWatch Alarm that sends alerts to Slack, use this topic ARN for the `alarm_actions` and `ok_actions` options.

*Example:* [/application/ndelius/cloudwatch.tf](/application/ndelius/cloudwatch.tf)
```hcl
data "terraform_remote_state" "alerts" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/alerts/terraform.tfstate"
    region = var.region
  }
}

resource "aws_cloudwatch_metric_alarm" "response_time_warning_alarm" {
  # ...
  alarm_actions = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
  ok_actions    = [data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn]
}
```