output "api_service" {
  value = {
    id = "${aws_ecs_service.api_service.id}"
  }
}

output "primary_db" {
  value = {
    id = "${aws_db_instance.primary.id}"
    name = "${aws_db_instance.primary.name}"
    address = "${aws_db_instance.primary.address}"
    port = "${aws_db_instance.primary.port}"
    endpoint = "${aws_db_instance.primary.endpoint}"
  }
}