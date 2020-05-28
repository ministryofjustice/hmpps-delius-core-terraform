resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.environment_name}-${local.app_name}-task-definition"
  container_definitions    = "${data.template_file.container_definition.rendered}"
  task_role_arn            = "${aws_iam_role.task.arn}"
  execution_role_arn       = "${aws_iam_role.exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${local.umt_config["memory"]}"
  cpu                      = "${local.umt_config["cpu"]}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${var.environment_name}-${local.app_name}-task-definition"))}"
}

resource "aws_ecs_service" "service" {
  name            = "${var.short_environment_name}-${local.app_name}-service"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.task_definition.arn}"

  health_check_grace_period_seconds = 180

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.ndelius.umt_targetgroup_arn}"
    container_name   = "${local.app_name}"
    container_port   = "8080"
  }
  load_balancer {
    target_group_arn = "${data.terraform_remote_state.interface.umt_targetgroup_arn}"
    container_name   = "${local.app_name}"
    container_port   = "8080"
  }
  load_balancer {
    target_group_arn = "${data.terraform_remote_state.spg.umt_targetgroup_arn}"
    container_name   = "${local.app_name}"
    container_port   = "8080"
  }
  service_registries {
    registry_arn   = "${aws_service_discovery_service.web_svc_record.arn}"
    container_name = "${local.app_name}"
  }
  network_configuration = {
    subnets         = ["${list(
      data.terraform_remote_state.vpc.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.vpc_private-subnet-az3,
    )}"]
    security_groups = ["${data.terraform_remote_state.delius_core_security_groups.sg_umt_instances_id}"]
  }
  depends_on = ["aws_iam_role.task"]
  lifecycle {
    ignore_changes = ["desired_count"]
  }
}

# ECS autoscaling
resource "aws_appautoscaling_target" "scaling_target" {
  min_capacity       = "${local.umt_config["ecs_scaling_min_capacity"]}"
  max_capacity       = "${local.umt_config["ecs_scaling_max_capacity"]}"
  resource_id        = "service/${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_name}/${aws_ecs_service.service.name}"
  role_arn           = "${aws_iam_role.exec.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # Use lifecycle rule as workaround for role_arn being changed every time due to
  # role_arn being required field but AWS will always switch this to the auto created service role
  lifecycle {
    ignore_changes = "role_arn"
  }
}

resource "aws_appautoscaling_policy" "scaling_policy" {
  name                       = "${var.environment_name}-${local.app_name}-cpu-scaling-policy"
  policy_type                = "TargetTrackingScaling"
  resource_id                = "${aws_appautoscaling_target.scaling_target.resource_id}"
  scalable_dimension         = "${aws_appautoscaling_target.scaling_target.scalable_dimension}"
  service_namespace          = "${aws_appautoscaling_target.scaling_target.service_namespace}"
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value             = "${local.umt_config["ecs_target_cpu"]}"
  }
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "web_svc_record" {
  name = "${local.app_name}"
  dns_config {
    namespace_id = "${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["id"]}"
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
