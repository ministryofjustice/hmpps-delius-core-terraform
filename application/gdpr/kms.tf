# This encryption key is used for copying automatic snapshots so that they are available for copying to other environments
# using a symmetric shared key.   The key is NOT currently used for the RDS instance itself, which defaults to using the aws/rds key.
# Production Databases may be copied to Stage or Pre-Prod
# Test Databases may be copied to Dev

module "kms_custom_policy" {
  source                  = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git//modules//kms_custom_policy?ref=terraform-0.12"
  kms_key_name            = local.common_name
  policy                  = data.aws_iam_policy_document.gdpr_rds_kms_policy_document.json
  tags                    = var.tags
}

data "aws_iam_policy_document" "gdpr_rds_kms_policy_document" {
 statement {
    sid = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = ["kms:*"]
    resources = ["*"]
  }
 statement {
    sid = "Allow access for Key Administrators"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
                     "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.short_environment_name}-server-provison-ec2-role"]
    }
    actions = ["kms:Create*","kms:Describe*","kms:Enable*","kms:List*","kms:Put*","kms:Update*","kms:Revoke*",
               "kms:Disable*","kms:Get*","kms:Delete*","kms:TagResource","kms:UntagResource",
               "kms:ScheduleKeyDeletion","kms:CancelKeyDeletion"]
    resources = ["*"]
  }
 statement {
    sid = "Allow access to Key in target environment"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform"],
                     var.environment_name == "delius-test" ? ["arn:aws:iam::${var.aws_account_ids["delius-core-non-prod"]}:role/terraform"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-pre-prod"]}:role/terraform"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-stage"]}:role/terraform"]:[])
    }
    actions = ["kms:CreateGrant","kms:DescribeKey"]
    resources = ["*"]
  }

}