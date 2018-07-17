vpc_cidr = "10.161.128.128/25"

project_name = "delius-core"

environment_type = "playpit"

bastion_account_id = "895523100917"
bastion_vpc_id = "vpc-00d48e9851c261b47"

tags = {
  owner                  = "Digital Studio"
  environment-name       = "delius-core-playpit"
  application            = "delius-core"
  is-production          = "false"
  business-unit          = "hmpps"
  infrastructure-support = "Digital Studio"
  region                 = "eu-west-2"
  provisioned-with       = "Terraform"
}

instance_type_weblogic = "t2.large"

instance_type_db = "t2.large"
