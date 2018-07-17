output "weblogic_private_ip" {
  value = "${aws_instance.weblogic.private_ip}"
}

output "db_private_ip" {
  value = "${aws_instance.db.private_ip}"
}
