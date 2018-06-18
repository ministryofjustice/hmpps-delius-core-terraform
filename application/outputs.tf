output "weblogic_public_ip" {
  value = "${aws_instance.weblogic.public_ip}"
}

output "weblogic_private_ip" {
  value = "${aws_instance.weblogic.private_ip}"
}

output "db_public_ip" {
  value = "${aws_instance.db.public_ip}"
}

output "db_private_ip" {
  value = "${aws_instance.db.private_ip}"
}
