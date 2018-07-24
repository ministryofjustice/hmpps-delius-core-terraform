data "aws_route53_zone" "zone" {
  name         = "${var.environment_type}.${var.project_name}.${var.route53_domain_private}."
  private_zone = false
}