output "weblogic_public_ip" {
  value = "${aws_instance.weblogic.public_ip}"
}

output "weblogic_private_ip" {
  value = "${aws_instance.weblogic.private_ip}"
}
