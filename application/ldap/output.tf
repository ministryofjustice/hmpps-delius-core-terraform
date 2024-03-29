output "private_fqdn_ldap_elb" {
  value = aws_route53_record.ldap_elb_private.fqdn
}

output "ldap_port" {
  value = var.ldap_ports["ldap"]
}

output "ldap_protocol" {
  value = local.ldap_config["protocol"]
}

output "ldap_base" {
  value = local.ldap_config["base_root"]
}

output "ldap_base_users" {
  value = local.ldap_config["base_users"]
}

output "ldap_bind_user" {
  value = local.ldap_config["bind_user"]
}

output "asg" {
  value = {
    "id"   = aws_autoscaling_group.asg.id
    "arn"  = aws_autoscaling_group.asg.arn
    "name" = aws_autoscaling_group.asg.name
  }
}

output "lb" {
  value = {
    "id"   = contains(local.migrated_envs, var.environment_name) ? null : aws_elb.lb[0].id
    "arn"  = contains(local.migrated_envs, var.environment_name) ? null : aws_elb.lb[0].arn
    "name" = contains(local.migrated_envs, var.environment_name) ? null : aws_elb.lb[0].name
  }
}

output "efs" {
  value = {
    "id"             = aws_efs_file_system.efs.id
    "arn"            = aws_efs_file_system.efs.arn
    "dns_name"       = aws_efs_file_system.efs.dns_name
    "creation_token" = aws_efs_file_system.efs.creation_token
  }
}

output "healthy_hosts_alarm_arn" {
  value = contains(local.migrated_envs, var.environment_name) ? null : aws_cloudwatch_metric_alarm.ldap_healthy_hosts_fatal_alarm[0].arn
}

