data "template_file" "user_data" {
  template = file("${path.module}/user_data/user_data.sh")

  vars = {
    project_name         = var.project_name
    env_identifier       = var.environment_identifier
    short_env_identifier = var.short_environment_identifier
    region               = var.region
    server_name          = local.server_name
    route53_sub_domain   = var.environment_name
    private_domain       = local.private_domain
    account_id           = local.vpc_account_id
    bastion_inventory    = local.bastion_inventory

  }
}
