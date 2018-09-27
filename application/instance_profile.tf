module "s3_access_role" {
  source                  = "../modules/iam_roles/server_provision_ec2_role"
  role_name               = "${var.environment_name}-server-provision-ec2-role"
  environment_name        = "${var.environment_name}"
  dependencies_bucket_arn = "${var.dependencies_bucket_arn}"
}
