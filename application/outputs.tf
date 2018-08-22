output "db_public_dns" {
  value = "${aws_route53_record.db.fqdn}"
}

output "db_private_ip" {
  value = "${aws_instance.db.private_ip}"
}

output "oid_db_public_dns" {
  value = "${aws_route53_record.oid_db.fqdn}"
}

output "oid_db_private_ip" {
  value = "${aws_instance.oid_db.private_ip}"
}
