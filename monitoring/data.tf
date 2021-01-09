data "aws_caller_identity" "current" {
}

data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "spg" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/spg/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "interface" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/interface/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ldap" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "batch" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/batch/dss/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/database_failover/terraform.tfstate"
    region = var.region
  }
}

data "template_file" "delius_service_health_dashboard_file" {
  template = file("./templates/cloudwatch/delius-service-health.json")
  vars = {
    region                       = var.region
    log_group_weblogic_ndelius   = data.terraform_remote_state.ndelius.outputs.cloudwatch_log_group
    log_group_weblogic_interface = data.terraform_remote_state.interface.outputs.cloudwatch_log_group
    log_group_weblogic_spg       = data.terraform_remote_state.spg.outputs.cloudwatch_log_group
    alb_ndelius                  = local.ndelius_alb_id
    asg_ndelius                  = data.terraform_remote_state.ndelius.outputs.asg["name"]
    asg_interface                = data.terraform_remote_state.interface.outputs.asg["name"]
    asg_spg                      = data.terraform_remote_state.spg.outputs.asg["name"]
    asg_ldap                     = data.terraform_remote_state.ldap.outputs.asg["name"]
    instance_delius_db_1         = data.terraform_remote_state.db.outputs.ami_delius_db_1
    alarm_activemq               = aws_cloudwatch_metric_alarm.activemq_healthy_hosts_fatal_alarm.arn
    alarm_ldap                   = aws_cloudwatch_metric_alarm.ldap_healthy_hosts_fatal_alarm.arn
    alarm_weblogic_interface     = module.interface_weblogic_alarms.healthy_hosts_warning_alarm
    alarm_weblogic_ndelius       = module.ndelius_weblogic_alarms.healthy_hosts_warning_alarm
    alarm_weblogic_spg           = module.spg_weblogic_alarms.healthy_hosts_warning_alarm
  }
}

data "archive_file" "alarm_lambda_handler_zip" {
  type        = "zip"
  output_path = "${path.module}/files/${local.lambda_name_alarm}.zip"
  source {
    content  = file("${path.module}/templates/lambda/notify-slack-alarm.js")
    filename = "notify-slack-alarm.js"
  }
}

data "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
}

data "archive_file" "batch_lambda_handler_zip" {
  type        = "zip"
  output_path = "${path.module}/files/${local.lambda_name_batch}.zip"
  source {
    content  = file("${path.module}/templates/lambda/notify-slack-batch.js")
    filename = "notify-slack-batch.js"
  }
}

