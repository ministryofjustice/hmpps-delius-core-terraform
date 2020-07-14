module "ecs_service" {
  source                 = "../../modules/ecs_service"
  region                 = "${var.region}"
  short_environment_name = "${var.short_environment_name}"
  tags                   = "${var.tags}"

  service_name                      = "${local.app_name}"
  container_definition              = "${data.template_file.container_definition.rendered}"
  required_cpu                      = "${local.aptracker_api_config["cpu"]}"
  required_memory                   = "${local.aptracker_api_config["memory"]}"
  min_capacity                      = "${local.aptracker_api_config["ecs_scaling_min_capacity"]}"
  max_capacity                      = "${local.aptracker_api_config["ecs_scaling_max_capacity"]}"
  target_cpu_usage                  = "${local.aptracker_api_config["ecs_target_cpu"]}"
  vpc_id                            = "${data.terraform_remote_state.vpc.vpc_id}"
  lb_listener_arn                   = "${data.terraform_remote_state.ndelius.lb_listener_arn}"
  lb_path_patterns                  = ["/aptracker-api", "/aptracker-api/*"]
  health_check_path                 = "/aptracker-api/actuator/health"
  health_check_grace_period_seconds = 180

  ecs_cluster = {
    name         = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_name}"
    cluster_id   = "${data.terraform_remote_state.ecs_cluster.shared_ecs_cluster_id}"
    namespace_id = "${data.terraform_remote_state.ecs_cluster.private_cluster_namespace["id"]}"
  }

  subnets = [
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}",
    "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}",
  ]

  security_groups = [
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_aptracker_api_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_umt_auth_id}",
  ]

  allowed_ssm_parameters = [
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/apacheds/apacheds/aptracker_user",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/apacheds/apacheds/aptracker_password",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/delius-database/db/delius_app_schema_password",
  ]
}
