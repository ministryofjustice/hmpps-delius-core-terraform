resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment_name}-pwm-cluster"
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-pwm-cluster"))}"
}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"
  vars {
    image_url       = "${local.image_url}"
    image_version   = "${local.image_version}"
    config_location = "${local.config_location}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.environment_name}-pwm-task-definition"
  container_definitions = "${data.template_file.container_definition.rendered}"
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-pwm-task-definition"))}"
  volume {
    name      = "pwm"
    host_path = "${local.config_location}"
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.environment_name}-pwm-service"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  desired_count   = "1"
  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name = "pwm"
    container_port = 8080
  }
}