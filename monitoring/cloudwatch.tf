resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Delius-ServiceHealth"
  dashboard_body = "${data.template_file.delius_service_health_dashboard_file.rendered}"
}
