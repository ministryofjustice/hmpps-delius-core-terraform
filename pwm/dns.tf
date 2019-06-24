resource "aws_route53_record" "private_dns" {
  zone_id = "${data.aws_route53_zone.private.id}"
  name    = "accounts"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.nlb.dns_name}"]
}

resource "aws_route53_record" "public_dns" {
  zone_id = "${data.aws_route53_zone.public.id}"
  name    = "accounts"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.nlb.dns_name}"]
}