#-------------------------------------------------------------
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sub project security groups
#-------------------------------------------------------------
data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}
#-------------------------------------------------------------
### Getting the shared vpc security groups
#-------------------------------------------------------------
data "terraform_remote_state" "vpc_security_groups" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "security-groups/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the sub project keys and profiles
#-------------------------------------------------------------
data "terraform_remote_state" "key_profile" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/key_profile/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the notification resources for Slack alerts
#-------------------------------------------------------------
data "terraform_remote_state" "alerts" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/alerts/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### test instance AMI
# #-------------------------------------------------------------
# data "aws_ami" "amazon_ami" {
#   owners      = ["895523100917"]
#   most_recent = true
# 
#   filter {
#     name   = "name"
#     values = ["HMPPS Base Amazon Linux 2 LTS master *"]
#   }
# 
#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# 
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
# }
