output "private_fqdn_ldap_elb" {
  value = "${aws_route53_record.ldap_elb_private.fqdn}"
}

output "public_fqdn_ldap_elb" {
  value = "${aws_route53_record.ldap_elb_public.fqdn}"
}

output "private_fqdn_readonly_ldap_elb" {
  value = "${aws_route53_record.ldap_readonly_elb_private.fqdn}"
}

output "public_fqdn_readonly_ldap_elb" {
  value = "${aws_route53_record.ldap_readonly_elb_public.fqdn}"
}

output "ldap_port" {
  value = "${var.ldap_port}"
}

output "ldap_protocol" {
  value = "${var.ansible_vars["ldap_protocol"]}"
}

output "ldap_base" {
  value = "${var.ansible_vars["base_root"]}"
}

output "ldap_bind_user" {
  value = "${var.ansible_vars["bind_user"]}"
}