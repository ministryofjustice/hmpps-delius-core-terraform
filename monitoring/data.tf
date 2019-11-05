data "aws_caller_identity" "current" {}

data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "spg" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/spg/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "interface" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/interface/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "ldap" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/database_failover/terraform.tfstate"
    region = "${var.region}"
  }
}

data "template_file" "delius_service_health_dashboard_file" {
  template = "${file("./templates/cloudwatch/delius-service-health.json")}"
  vars {
    region                        = "${var.region}"
    log_group_weblogic_ndelius    = "${data.terraform_remote_state.ndelius.cloudwatch_log_group}"
    log_group_weblogic_interface  = "${data.terraform_remote_state.interface.cloudwatch_log_group}"
    log_group_weblogic_spg        = "${data.terraform_remote_state.spg.cloudwatch_log_group}"
    alb_ndelius                   = "${local.ndelius_alb_id}"
    asg_ndelius                   = "${data.terraform_remote_state.ndelius.asg["name"]}"
    asg_interface                 = "${data.terraform_remote_state.interface.asg["name"]}"
    asg_spg                       = "${data.terraform_remote_state.spg.asg["name"]}"
    asg_ldap                      = "${data.terraform_remote_state.ldap.asg["name"]}"
    instance_delius_db_1          = "${data.terraform_remote_state.db.ami_delius_db_1}"
  }
}
