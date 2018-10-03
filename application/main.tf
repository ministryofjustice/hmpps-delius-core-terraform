# terraform {
#   # The configuration for this backend will be filled in by Terragrunt
#   backend          "s3"             {}
#   required_version = "~> 0.11"
# }
#
# provider "aws" {
#   region  = "${var.region}"
#   version = "~> 1.16"
# }
#
# # Shared data and constants
#
# locals {
#   environment_name = "${var.project_name}-${var.environment_type}"
# }
#
# data "aws_vpc" "vpc" {
#   tags = {
#     Name = "${local.environment_name}"
#   }
# }
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 1.16"
}

#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "vpc/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the shared vpc security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

#-------------------------------------------------------------
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

data "aws_ami" "centos" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos_wls" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Delius-Core Weblogic master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_ami" "centos_oracle_db" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Delius-Core OracleDB master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# data "template_file" "user_data" {
#   template = "${file("./user_data/user_data.sh")}"
#
#   vars {
#     env_identifier          = "${var.environment_identifier}"
#     short_env_identifier    = "${var.short_environment_identifier}"
#     app_name                = "${local.server_name}"
#     # cldwatch_log_group      = "${module.create_loggroup.loggroup_name}"
#     region                  = "${var.region}"
#     # cache_home              = "${var.cache_home}"
#     # ebs_device              = "${var.ebs_device_name}"
#     route53_sub_domain      = "${data.terraform_remote_state.vpc.environment_name}"
#     private_domain          = "${data.terraform_remote_state.vpc.private_zone_name}"
#     account_id              = "${data.terraform_remote_state.vpc.vpc_account_id}"
#     internal_domain         = "${data.terraform_remote_state.vpc.private_zone_name}"
#     # monitoring_server_url   = "${data.terraform_remote_state.monitoring-server.monitoring_internal_dns}"
#     # monitoring_cluster_name = "${var.short_environment_identifier}-es-cluster"
#     # cluster_subnet          = ""
#     # cluster_name            = "${var.environment_identifier}-public-ecs-cluster"
#     # db_name                 = "${data.terraform_remote_state.rds.service_alfresco_rds_db_instance_database_name}"
#     # db_host                 = "${data.terraform_remote_state.rds.service_alfresco_rds_db_instance_endpoint_cname}"
#     # db_user                 = "${data.terraform_remote_state.rds.service_alfresco_rds_db_instance_username}"
#     # db_password             = "${data.aws_ssm_parameter.db_password.value}"
#     server_mode             = "TEST"
#   }
# }
