resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "${var.event_name}-rule"
  description = var.event_desc

  # Either cron expression where cron time will be region local time or rate format
  # Note - not standard cron format - see:
  # https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
  schedule_expression = var.event_schedule
}

# Create an IAM role for the event target to run under
data "template_file" "event_assume_role_policy_template" {
  template = file(
    "${path.module}/templates/iam_policies/event_assume_role.tpl",
  )

  vars = {}
}

resource "aws_iam_role" "event_role" {
  name = "${var.event_name}-event-role"

  assume_role_policy = data.template_file.event_assume_role_policy_template.rendered
}

# Creata and attach IAM policy to allow event to submit batch jobs to target queue
data "template_file" "event_policy_template" {
  template = file("${path.module}/templates/iam_policies/event_policy.tpl")

  vars = {
    job_queue_arn      = var.event_job_queue_arn
    job_definition_arn = var.event_job_def_arn
  }
}

resource "aws_iam_role_policy" "cloudwatch_batch_role" {
  name = "cloudwatch_batch_policy"
  role = aws_iam_role.event_role.name

  policy = data.template_file.event_policy_template.rendered
}

resource "aws_cloudwatch_event_target" "event_target" {
  # UID
  target_id = "${var.event_name}-scheduled-event"
  rule      = aws_cloudwatch_event_rule.event_rule.name

  # Target ARN refers to the batch job queue to submit a job to
  arn = var.event_job_queue_arn

  # IAM Role ARN for the Cloudwatch Event trigger
  role_arn = aws_iam_role.event_role.arn

  batch_target {
    job_name       = "${var.event_name}-job"
    job_definition = var.event_job_def_arn
    job_attempts   = var.event_job_attempts
  }
}

