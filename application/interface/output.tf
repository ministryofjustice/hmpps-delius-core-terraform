output "private_fqdn_interface_wls_external" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn_interface_wls_external" {
  value = "${aws_route53_record.public_dns.fqdn}"
}

output "private_fqdn_interface_wls_internal_alb" {
  value = "${module.interface.private_fqdn_internal_alb}"
}

output "cloudwatch_log_group" {
  value = "${module.interface.cloudwatch_log_group}"
}

output "asg" {
  value = "${module.interface.asg}"
}

output "alb" {
  value = "${module.interface.alb}"
}

output "ami_interface_wls" {
  value = "${data.aws_ami.centos_wls.id} - ${data.aws_ami.centos_wls.name}"
}

output "newtech_webfrontend_target_group_arn" {
  value = "${module.interface.newtech_webfrontend_targetgroup_arn}"
}

output "umt_targetgroup_arn" {
  value = "${module.interface.umt_targetgroup_arn}"
}
