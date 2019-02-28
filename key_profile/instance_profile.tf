# Roles and policies for ec2 server provsioning

module "server_provision_ec2_role" {
  source                  = "../modules/iam_roles/server_provision_ec2_role"
  role_name               = "${var.short_environment_name}-server-provison-ec2-role"
  environment_name        = "${var.short_environment_name}"
  dependencies_bucket_arn = "${var.dependencies_bucket_arn}"
  backups_bucket_arn      = "${data.terraform_remote_state.s3bucket.s3_bucket_arn}"
}

output "instance_profile_ec2_id" {
  value = "${module.server_provision_ec2_role.instance_profile_ec2_id}"
}

output "instance_profile_ec2_arn" {
  value = "${module.server_provision_ec2_role.instance_profile_ec2_arn}"
}
