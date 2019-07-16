output "private_fqdn" {
  value = "${aws_route53_record.private_dns.fqdn}"
}

output "public_fqdn" {
  value = "${aws_route53_record.public_dns.fqdn}"
}

output "asg" {
  value = {
    id = "${aws_autoscaling_group.asg.id}"
    arn = "${aws_autoscaling_group.asg.arn}"
  }
}