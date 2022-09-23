locals {
  # Only scale up the service in the following environments:
  target_environments = [
    "delius-test",
    "delius-pre-prod",
    "delius-prod"
  ]
  min_capacity = contains(local.target_environments, var.environment_name) ? 2 : 0
  max_capacity = contains(local.target_environments, var.environment_name) ? 10 : 0

  certificate_arn = var.delius_core_public_zone == "strategic" ? data.aws_acm_certificate.strategic_cert.arn : data.aws_acm_certificate.legacy_cert.arn
  route53_zone_id = var.delius_core_public_zone == "strategic" ? data.terraform_remote_state.vpc.outputs.strategic_public_zone_id : data.terraform_remote_state.vpc.outputs.public_zone_id

  natgateway_public_ips_cidr_blocks = [
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az1}/32",
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az2}/32",
    "${data.terraform_remote_state.natgateway.outputs.natgateway_common-nat-public-ip-az3}/32",
  ]
  bastion_public_ip = ["${data.terraform_remote_state.bastion.outputs.bastion_ip}/32"]
}
