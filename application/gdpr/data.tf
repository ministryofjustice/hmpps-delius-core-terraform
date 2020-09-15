data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/database_failover/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "ecs-cluster/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = var.region
  }
}

data "aws_route53_zone" "public" {
  zone_id = data.terraform_remote_state.vpc.outputs.public_zone_id
}

data "aws_caller_identity" "current" {
}

data "template_file" "api_container_definition" {
  template = file("templates/ecs/api_container_definition.json.tpl")
  vars = {
    # environment
    region           = var.region
    aws_account_id   = data.aws_caller_identity.current.account_id
    environment_name = var.environment_name
    project_name     = var.project_name
    # container properties
    container_name = local.api_name
    image_url      = "${local.gdpr_config["api_image_url"]}:${local.gdpr_config["api_version"]}"
    memory         = local.gdpr_config["api_memory"]
    cpu            = local.gdpr_config["api_cpu"]
    # logging
    log_group_name = "${var.environment_name}/${local.app_name}"
    log_level      = local.gdpr_config["log_level"]
    # application config
    alfresco_host                = "${local.ansible_vars["alfresco_host"]}.${replace(data.aws_route53_zone.public.name, "/\\.$/", "")}" # Trim trailing period if present
    cron_identifyduplicates      = local.gdpr_config["cron_identifyduplicates"]
    cron_retainedoffenders       = local.gdpr_config["cron_retainedoffenders"]
    cron_retainedoffendersiicsa  = local.gdpr_config["cron_retainedoffendersiicsa"]
    cron_eligiblefordeletion     = local.gdpr_config["cron_eligiblefordeletion"]
    cron_deleteoffenders         = local.gdpr_config["cron_deleteoffenders"]
    cron_destructionlogclearing  = local.gdpr_config["cron_destructionlogclearing"]
    delius_database_url          = data.terraform_remote_state.database.outputs.jdbc_failover_url
    delius_database_username     = "gdpr_pool"
    delius_database_password_key = "delius-database/db/gdpr_pool_password"
    gdpr_database_url            = "jdbc:postgresql://${aws_db_instance.primary.endpoint}/${aws_db_instance.primary.name}"
    gdpr_database_username       = aws_db_instance.primary.username
    oauth_token_uri              = "https://${data.terraform_remote_state.ndelius.outputs.public_fqdn_ndelius_wls_external}/umt/oauth/check_token"
  }
}

data "template_file" "ui_container_definition" {
  template = file("templates/ecs/ui_container_definition.json.tpl")
  vars = {
    # environment
    region           = var.region
    aws_account_id   = data.aws_caller_identity.current.account_id
    environment_name = var.environment_name
    project_name     = var.project_name
    # container properties
    container_name = local.ui_name
    image_url      = "${local.gdpr_config["ui_image_url"]}:${local.gdpr_config["ui_version"]}"
    memory         = local.gdpr_config["ui_memory"]
    cpu            = local.gdpr_config["ui_cpu"]
    # logging
    log_group_name = "${var.environment_name}/${local.app_name}"
    log_level      = local.gdpr_config["log_level"]
    # application config
    nginx_config   = replace(file("nginx/default.conf"), "\n", "")
    angular_config = replace(file("angular/config.js"), "\n", "")
  }
}

