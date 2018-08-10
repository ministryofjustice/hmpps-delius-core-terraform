output "app_test_dns_fqdn" {
  value = "${aws_route53_record.app_test.fqdn}"
}

output "app_test_private_ip" {
  value = "${aws_instance.app_test.private_ip}"
}
