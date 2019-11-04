output "private_fqdn_ndelius_wls_external" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn_ndelius_wls_external" {
  value = "${aws_route53_record.public_dns.fqdn}"
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