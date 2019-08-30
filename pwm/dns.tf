resource "aws_route53_record" "internal_lb_private_dns" {
  zone_id = "${data.aws_route53_zone.private.id}"
  name    = "password-reset"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.alb.dns_name}"]
}

resource "aws_route53_record" "public_dns" {
  zone_id = "${data.aws_route53_zone.public.id}"
  name    = "password-reset"
  type    = "CNAME"
  ttl     = "300"
  records = ["${module.external_nlb.dns_name}"]
}