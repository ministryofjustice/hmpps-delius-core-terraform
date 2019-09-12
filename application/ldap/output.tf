output "private_fqdn_ldap_elb" {
  value = "${aws_route53_record.ldap_elb_private.fqdn}"
}

output "ldap_port" {
  value = "${var.ldap_ports["ldap"]}"
}

output "ldap_protocol" {
  value = "${local.ansible_vars_apacheds["ldap_protocol"]}"
}

output "ldap_base" {
  value = "${local.ansible_vars_apacheds["base_root"]}"
}

output "ldap_base_users" {
  value = "${local.ansible_vars_apacheds["base_users"]}"
}

output "ldap_bind_user" {
  value = "${local.ansible_vars_apacheds["bind_user"]}"
}