locals {
  app_name   = "delius-api"
  short_name = "api"
  app_config = merge(var.default_delius_api_config, var.delius_api_config)
  environment = merge(var.delius_api_environment, {
    SPRING_DATASOURCE_URL = data.terraform_remote_state.database.outputs.jdbc_failover_url
    # Add any environment variables here that should be pulled from Terraform data sources
  })
  secrets = { for key, value in var.delius_api_secrets : key => "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${value}" }
  security_groups = {
    load_balancer = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_api_lb_id]
    instances = [
      data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
      data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_api_instances_id
    ]
  }
  subnets = {
    private = [
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
    ]
    public = [
      data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az1,
      data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az2,
      data.terraform_remote_state.vpc.outputs.vpc_public-subnet-az3,
    ]
  }
}

