output "dns_name" {
  value = "${aws_lb.external_nlb.dns_name}"
}