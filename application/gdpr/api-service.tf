
resource "aws_ecs_task_definition" "api_task_definition" {
  family                   = "${var.environment_name}-${local.api_name}-task-definition"
  container_definitions    = "${data.template_file.api_container_definition.rendered}"
  task_role_arn            = "${aws_iam_role.task.arn}"
  execution_role_arn       = "${aws_iam_role.exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${local.gdpr_config["api_memory"]}"
  cpu                      = "${local.gdpr_config["api_cpu"]}"
  requires_compatibilities = ["EC2"]
  tags                     = "${merge(var.tags, map("Name", "${var.environment_name}-${local.api_name}-task-definition"))}"
}

resource "aws_ecs_service" "api_service" {
  name            = "${var.short_environment_name}-${local.api_name}-service"
  cluster         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
  task_definition = "${aws_ecs_task_definition.api_task_definition.arn}"
  desired_count   = 1 # Fix to a single instance, as currently the batch processes cannot be scaled horizontally
  load_balancer {
    container_name   = "${local.api_name}"
    container_port   = 8080
    target_group_arn = "${data.terraform_remote_state.ndelius.gdpr_api_targetgroup_arn}"
  }
  load_balancer {
    container_name   = "${local.api_name}"
    container_port   = 8080
    target_group_arn = "${data.terraform_remote_state.spg.gdpr_api_targetgroup_arn}"
  }
  load_balancer {
    container_name   = "${local.api_name}"
    container_port   = 8080
    target_group_arn = "${data.terraform_remote_state.interface.gdpr_api_targetgroup_arn}"
  }
  service_registries {
    registry_arn   = "${aws_service_discovery_service.api_web_svc_record.arn}"
    container_name = "${local.api_name}"
  }
  network_configuration = {
    subnets         = ["${list(
      data.terraform_remote_state.vpc.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.vpc_private-subnet-az3,
    )}"]
    security_groups = [
      "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
      "${data.terraform_remote_state.delius_core_security_groups.sg_umt_auth_id}",
      "${data.terraform_remote_state.delius_core_security_groups.sg_gdpr_api_id}"
    ]
  }
  depends_on = ["aws_iam_role.task"]
}

# Create a service record in the ecs cluster's private namespace
resource "aws_service_discovery_service" "api_web_svc_record" {
  name = "${local.api_name}"
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
