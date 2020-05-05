output "private_fqdn_ldap_elb" {
  value = "${aws_route53_record.ldap_elb_private.fqdn}"
}

output "ldap_port" {
  value = "${var.ldap_ports["ldap"]}"
}

output "ldap_protocol" {
  value = "${local.ldap_config["protocol"]}"
}

output "ldap_base" {
  value = "${local.ldap_config["base_root"]}"
}

output "ldap_base_users" {
  value = "${local.ldap_config["base_users"]}"
}

output "ldap_bind_user" {
  value = "${local.ldap_config["bind_user"]}"
}

output "asg" {
  value = {
    "id"    = "${aws_autoscaling_group.asg.id}",
    "arn"   = "${aws_autoscaling_group.asg.arn}",
    "name"  = "${aws_autoscaling_group.asg.name}",
  }
}

output "lb" {
  value = {
    "id"    = "${aws_elb.lb.id}",
    "arn"   = "${aws_elb.lb.arn}",
    "name"  = "${aws_elb.lb.name}",
  }
}