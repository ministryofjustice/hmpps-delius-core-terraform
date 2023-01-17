# This encryption key is used for copying automatic snapshots so that they are available for copying to other environments
# using a symmetric shared key.   The key is NOT currently used for the RDS instance itself, which defaults to using the aws/rds key.
# Production Databases may be copied to Stage or Pre-Prod
# Test Databases may be copied to Dev

module "kms_custom_policy" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules//kms_custom_policy?ref=terraform-0.12"
  kms_key_name            = local.common_name
  policy                  = module.rds_kms_policy_document.aws_iam_policy_document_content.json
  tags                    = var.tags
}

module "rds_kms_policy_document" {
  source = "../../modules/rds_kms_policy_document"
  environment_name        = var.environment_name
  short_environment_name  = var.short_environment_name
  aws_account_ids         = var.aws_account_ids
}