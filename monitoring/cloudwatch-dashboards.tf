resource "aws_cloudwatch_dashboard" "delius_service_health" {
  dashboard_name = "${var.environment_name}-ServiceHealth"
  dashboard_body = "${data.template_file.delius_service_health_dashboard_file.rendered}"
}
