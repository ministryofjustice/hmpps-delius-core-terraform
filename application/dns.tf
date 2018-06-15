data "aws_route53_zone" "zone" {
  name         = "${var.environment_type}.${var.project_name}.${var.route53_domain_private}."
  private_zone = false
}

resource "aws_route53_record" "weblogic" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "weblogic"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.weblogic.public_ip}"]
}
