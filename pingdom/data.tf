data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/application/ndelius/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket_name}"
    key    = "delius-core/security-groups/terraform.tfstate"
    region = "${var.region}"
  }
}

data "terraform_remote_state" "pingdom_sns" {
  backend = "s3"
  config {
    bucket   = "${var.eng_remote_state_bucket_name}"
    role_arn = "${var.eng_role_arn}"
    key      = "pingdom/terraform.tfstate"
    region   = "${var.region}"
  }
}

data "aws_caller_identity" "current" {}