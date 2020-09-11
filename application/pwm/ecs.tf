module "service" {
  source                 = "../../modules/ecs_service"
  region                 = var.region
  short_environment_name = var.short_environment_name
  tags                   = var.tags

  service_name          = local.app_name
  container_definition  = data.template_file.container_definition.rendered
  required_cpu          = local.pwm_config["cpu"]
  required_memory       = local.pwm_config["memory"]
  min_capacity          = local.pwm_config["min_capacity"]
  max_capacity          = local.pwm_config["max_capacity"]
  target_cpu_usage      = local.pwm_config["target_cpu"]
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check_matcher  = "200-399"
  lb_stickiness_enabled = true

  ecs_cluster = {
    name         = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name
    cluster_id   = data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_id
    namespace_id = data.terraform_remote_state.ecs_cluster.outputs.private_cluster_namespace["id"]
  }

  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]

  security_groups = [
    data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
    data.terraform_remote_state.vpc_security_groups.outputs.sg_smtp_ses,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_pwm_instances_id,
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
  ]

  allowed_ssm_parameters = [
    "${local.ssm_prefix}/pwm/pwm/security_key",
    "${local.ssm_prefix}/pwm/pwm/config_password",
    "${local.ssm_prefix}/apacheds/apacheds/ldap_admin_password",
  ]
}

