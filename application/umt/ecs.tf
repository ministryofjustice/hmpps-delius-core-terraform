resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment_name}-${local.app_name}-cluster"
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${local.app_name}-cluster"))}"
}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"
  vars {
    region          = "${var.region}"
    container_name  = "${local.app_name}"
    image_url       = "${local.image_url}"
    image_version   = "${local.image_version}"
    config_location = "${local.config_location}"
    log_group_name  = "${var.environment_name}/${local.app_name}"
    memory          = "${var.umt_config["memory"]}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "${var.environment_name}-${local.app_name}-task-definition"
  container_definitions = "${data.template_file.container_definition.rendered}"
  tags                  = "${merge(var.tags, map("Name", "${var.environment_name}-${local.app_name}-task-definition"))}"
  volume {
    name      = "config"
    host_path = "${local.host_config_location}"
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.environment_name}-${local.app_name}-service"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_appautoscaling_target" "scaling_target" {
  min_capacity       = "${var.umt_config["ecs_scaling_min_capacity"]}"
  max_capacity       = "${var.umt_config["ecs_scaling_max_capacity"]}"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  role_arn           = "${aws_iam_role.ecs.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scaling_policy" {
  name                       = "${var.environment_name}-pwm-cpu-scaling-policy"
  policy_type                = "TargetTrackingScaling"
  resource_id                = "${aws_appautoscaling_target.scaling_target.resource_id}"
  scalable_dimension         = "${aws_appautoscaling_target.scaling_target.scalable_dimension}"
  service_namespace          = "${aws_appautoscaling_target.scaling_target.service_namespace}"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value             = "${var.umt_config["ecs_target_cpu"]}"
  }
}
