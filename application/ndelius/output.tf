output "private_fqdn_ndelius_wls_external" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn_ndelius_wls_external" {
  value = "${aws_route53_record.public_dns.fqdn}"
}

output "private_fqdn_ndelius_wls_internal_alb" {
  value = "${module.ndelius.private_fqdn_internal_alb}"
}

output "cloudwatch_log_group" {
  value = "${module.ndelius.cloudwatch_log_group}"
}

output "asg" {
  value = "${module.ndelius.asg}"
}

output "alb" {
  value = "${module.ndelius.alb}"
}

output "ami_ndelius_wls" {
  value = "${data.aws_ami.centos_wls.id} - ${data.aws_ami.centos_wls.name}"
}

output "newtech_webfrontend_target_group_arn" {
  value = "${module.ndelius.newtech_webfrontend_targetgroup_arn}"
}

output "umt_targetgroup_arn" {
  value = "${module.ndelius.umt_targetgroup_arn}"
}

output "aptracker_api_targetgroup_arn" {
  value = "${module.ndelius.aptracker_api_targetgroup_arn}"
}