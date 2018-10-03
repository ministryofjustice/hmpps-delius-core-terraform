output "public_fqdn" {
  value = "${aws_route53_record.oracle_db_instance_public.fqdn}"
}

output "internal_fqdn" {
  value = "${aws_route53_record.oracle_db_instance_internal.fqdn}"
}

output "private_ip" {
  value = "${aws_instance.oracle_db.private_ip}"
}
