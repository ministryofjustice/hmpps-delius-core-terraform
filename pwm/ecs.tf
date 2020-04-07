resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment_name}-pwm-cluster"
  tags = "${merge(var.tags, map("Name", "${var.environment_name}-pwm-cluster"))}"
}

data "template_file" "container_definition" {
  template = "${file("templates/ecs/container_definition.json.tpl")}"
  vars {
    region          = "${var.region}"
    container_name  = "${local.container_name}"
    image_url       = "${local.image_url}"
    image_version   = "${local.image_version}"
    config_location = "${local.config_location}"
    log_group_name  = "${var.environment_name}/${local.container_name}"
    memory          = "${var.pwm_config["memory"]}"
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
  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name = "pwm"
    container_port = 8080
  }
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

resource "aws_appautoscaling_target" "scaling_target" {
  min_capacity       = "${var.pwm_config["ecs_scaling_min_capacity"]}"
  max_capacity       = "${var.pwm_config["ecs_scaling_max_capacity"]}"
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.service.name}"
  role_arn           = "${aws_iam_role.ecs.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # Use lifecycle rule as workaround for role_arn being changed every time due to
  # role_arn being required field but AWS will always switch this to the auto created service role
  lifecycle {
    ignore_changes = "role_arn"
  }
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
    target_value             = "${var.pwm_config["ecs_target_cpu"]}"
  }
}
