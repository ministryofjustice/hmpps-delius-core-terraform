data "aws_caller_identity" "current" {
}

data "terraform_remote_state" "ndelius" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/weblogic-app/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "interface" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/weblogic-eis/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "pwm" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/pwm/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "community_api" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/community-api/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "new_tech" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/new-tech/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "umt" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/umt/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ldap" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/ldap/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "db" {
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
