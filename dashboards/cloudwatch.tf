resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = templatefile("${path.module}/templates/cloudwatch/delius-service-health.json", {
    region                       = var.region
    log_group_weblogic_ndelius   = data.terraform_remote_state.ndelius.outputs.cloudwatch_log_group
    log_group_weblogic_interface = data.terraform_remote_state.interface.outputs.cloudwatch_log_group
    log_group_weblogic_spg       = data.terraform_remote_state.spg.outputs.cloudwatch_log_group
    alb_ndelius                  = replace(data.terraform_remote_state.ndelius.outputs.alb.arn, "/.+:loadbalancer.{1}/", "")
    asg_ndelius                  = data.terraform_remote_state.ndelius.outputs.asg["name"]
    asg_interface                = data.terraform_remote_state.interface.outputs.asg["name"]
    asg_spg                      = data.terraform_remote_state.spg.outputs.asg["name"]
    asg_ldap                     = data.terraform_remote_state.ldap.outputs.asg["name"]
    instance_delius_db_1         = data.terraform_remote_state.db.outputs.ami_delius_db_1
    alarm_activemq               = data.terraform_remote_state.spg.outputs.activemq_healthy_hosts_alarm_arn
    alarm_ldap                   = data.terraform_remote_state.ldap.outputs.healthy_hosts_alarm_arn
    alarm_weblogic_interface     = data.terraform_remote_state.interface.outputs.weblogic_healthy_hosts_alarm_arn
    alarm_weblogic_ndelius       = data.terraform_remote_state.ndelius.outputs.weblogic_healthy_hosts_alarm_arn
    alarm_weblogic_spg           = data.terraform_remote_state.spg.outputs.weblogic_healthy_hosts_alarm_arn
  })
}

