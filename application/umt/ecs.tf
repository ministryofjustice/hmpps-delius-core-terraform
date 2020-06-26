module "ecs" {
  source                 = "../../modules/ecs_service"
  region                 = "${var.region}"
  project_name           = "${var.project_name}"
  environment_name       = "${var.environment_name}"
  short_environment_name = "${var.short_environment_name}"
  tags                   = "${var.tags}"

  service_name         = "${local.app_name}"
  container_definition = "${data.template_file.container_definition.rendered}"
  lb_target_group_arn  = "${data.terraform_remote_state.ndelius.umt_targetgroup_arn}"
  required_cpu         = "${local.umt_config["cpu"]}"
  required_memory      = "${local.umt_config["memory"]}"
  min_capacity         = "${local.umt_config["ecs_scaling_min_capacity"]}"
  max_capacity         = "${local.umt_config["ecs_scaling_max_capacity"]}"
  target_cpu_usage     = "${local.umt_config["ecs_scaling_target_cpu"]}"

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
    "${data.terraform_remote_state.delius_core_security_groups.sg_umt_instances_id}",
  ]

  required_ssm_parameters = [
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/apacheds/apacheds/ldap_admin_password",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/delius-database/db/delius_app_schema_password",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/umt/umt/jwt_secret",
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}/${var.project_name}/umt/umt/delius_secret",
  ]
}
