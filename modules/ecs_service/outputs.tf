output "service" {
  value = {
    id   = "${aws_ecs_service.service.id}"
    name = "${aws_ecs_service.service.name}"
  }
}
