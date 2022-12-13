module "prison-case-notes-to-probation" {
  source                   = "../../modules/ecs_service"
  region                   = var.region
  environment_name         = var.environment_name
  short_environment_name   = var.short_environment_name
  remote_state_bucket_name = var.remote_state_bucket_name
  tags                     = var.tags

  # Application Container
  service_name                   = "prison-case-notes-to-probation"
  ignore_task_definition_changes = true

  # Security & Networking
  task_role_arn      = aws_iam_role.ecs_sqs_task.arn
  target_group_count = 0 # no load balancer required
  security_groups = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_db_access_id
  ]

  # Monitoring
  notification_arn = data.terraform_remote_state.alerts.outputs.aws_sns_topic_alarm_notification_arn

  # Scaling
  min_capacity = var.environment_name == "delius-prod" ? 2 : 0
  max_capacity = var.environment_name == "delius-prod" ? 2 : 0
}

resource "aws_iam_role_policy_attachment" "prison-case-notes-to-probation" {
  role       = module.prison-case-notes-to-probation.exec_role.name
  policy_arn = aws_iam_policy.access_ssm_parameters.arn
}
