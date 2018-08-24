output "delius_db_public_dns" {
  value = "${aws_route53_record.delius_db.fqdn}"
}

output "delius_db_private_ip" {
  value = "${aws_instance.delius_db.private_ip}"
}

output "oid_db_public_dns" {
  value = "${aws_route53_record.oid_db.fqdn}"
}

output "oid_db_private_ip" {
  value = "${aws_instance.oid_db.private_ip}"
}
