resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = templatefile("${path.module}/templates/cloudwatch/delius-service-health.json", {
    region                 = var.region
    account_id             = data.aws_caller_identity.current.account_id
    environment_name       = var.environment_name
    short_environment_name = var.short_environment_name
    ecs_cluster            = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
    db_instance_id         = data.terraform_remote_state.db.outputs.ami_delius_db_1
    asg_ldap               = data.terraform_remote_state.ldap.outputs.asg["name"]
    task_definitions = {
      weblogic-app = data.terraform_remote_state.ndelius.outputs.service["task_definition_family"]
    }
    load_balancers = {
      weblogic-app = data.terraform_remote_state.ndelius.outputs.alb["arn_suffix"]
      weblogic-eis = data.terraform_remote_state.interface.outputs.alb["arn_suffix"]
      pwm          = data.terraform_remote_state.pwm.outputs.alb["arn_suffix"]
      community-api = [
        data.terraform_remote_state.community_api.outputs.alb["arn_suffix"],
        data.terraform_remote_state.community_api.outputs.public_alb["arn_suffix"],
        data.terraform_remote_state.community_api.outputs.legacy_alb["arn_suffix"],
      ]
    }
    target_groups = {
      weblogic-app = data.terraform_remote_state.ndelius.outputs.target_group["arn_suffix"]
      weblogic-eis = data.terraform_remote_state.interface.outputs.target_group["arn_suffix"]
      new-tech     = data.terraform_remote_state.new_tech.outputs.target_group["arn_suffix"]
      umt          = data.terraform_remote_state.umt.outputs.target_group["arn_suffix"]
      pwm          = data.terraform_remote_state.pwm.outputs.target_group["arn_suffix"]
    }
  })
}

