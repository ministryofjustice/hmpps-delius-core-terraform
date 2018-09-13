output "public_fqdn_delius_db" {
  value = "${aws_route53_record.delius_db_public.fqdn}"
}

output "internal_fqdn_delius_db" {
  value = "${aws_route53_record.delius_db_internal.fqdn}"
}

output "private_ip_delius_db" {
  value = "${aws_instance.delius_db.private_ip}"
}

output "public_fqdn_oid_db" {
  value = "${aws_route53_record.oid_db_public.fqdn}"
}

output "internal_fqdn_oid_db" {
  value = "${aws_route53_record.oid_db_internal.fqdn}"
}

output "private_ip_oid_db" {
  value = "${aws_instance.oid_db.private_ip}"
}

#
# output "oid_db_public_dns" {
#   value = "${aws_route53_record.oid_db.fqdn}"
# }
#
# output "oid_db_private_ip" {
#   value = "${aws_instance.oid_db.private_ip}"
# }

