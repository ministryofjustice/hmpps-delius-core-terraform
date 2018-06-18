vpc_cidr = "10.161.128.128/25"

project_name = "delius-core"

environment_type = "playpit"

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

instance_type_weblogic = "t2.micro"

instance_type_db = "t2.micro"
