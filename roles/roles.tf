# Roles and policies for ec2 server provsioning

module "server_provision_ec2_role" {
  source                  = "../modules/iam_roles/server_provision_ec2_role"
  role_name               = "${local.environment_name}-server-provison-ec2-role"
  environment_name        = "${local.environment_name}"
  dependencies_bucket_arn = "${var.dependencies_bucket_arn}"
}
