resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.environment_name}-${var.service_name}-task-definition"
  container_definitions    = "${var.container_definition}"
  task_role_arn            = "${aws_iam_role.task.arn}"
  execution_role_arn       = "${aws_iam_role.exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.required_memory}"
  cpu                      = "${var.required_cpu}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${var.environment_name}-${var.service_name}-task-definition"))}"
}

resource "aws_ecs_service" "service" {
  name            = "${var.short_environment_name}-${var.service_name}-service"
  cluster         = "${var.ecs_cluster["cluster_id"]}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"

  health_check_grace_period_seconds = "${var.health_check_grace_period_seconds}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.service_port}"
  }
  service_registries {
    registry_arn   = "${aws_service_discovery_service.web_svc_record.arn}"
    container_name = "${var.service_name}"
  }
  network_configuration = {
    subnets         = ["${var.subnets}"]
    security_groups = ["${var.security_groups}"]
  }
  depends_on = ["aws_iam_role.task"]
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "web_svc_record" {
  name = "${var.service_name}"
  dns_config {
    namespace_id = "${var.ecs_cluster["namespace_id"]}"
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
