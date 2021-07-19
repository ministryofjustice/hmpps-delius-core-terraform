resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = templatefile("${path.module}/templates/cloudwatch/delius-service-health.json", {
    region               = var.region
    asg_ldap             = data.terraform_remote_state.ldap.outputs.asg["name"]
    instance_delius_db_1 = data.terraform_remote_state.db.outputs.ami_delius_db_1
    alarm_ldap           = data.terraform_remote_state.ldap.outputs.healthy_hosts_alarm_arn
  })
}

