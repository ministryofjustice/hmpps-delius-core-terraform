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
    sid = "Allow use of the key"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/admin",
                     "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.short_environment_name}-server-provison-ec2-role"],
                     var.environment_name == "delius-test" ? ["arn:aws:iam::${var.aws_account_ids["delius-core-non-prod"]}:role/dlc-dev-server-provision-ec2-role"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-pre-prod"]}:role/del-pre-prod-server-provision-ec2-role"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-stage"]}:role/del-stage-server-provision-ec2-role"]:[])
    }
    actions = ["kms:Encrypt","kms:Decrypt","kms:ReEncrypt*","kms:GenerateDataKey*","kms:DescribeKey"]
    resources = ["*"]
  }
  statement {
    sid = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = concat(["arn:aws:ssm::${data.aws_caller_identity.current.account_id}:role/admin",
                     "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:role/${var.short_environment_name}-server-provison-ec2-role"],
                     var.environment_name == "delius-test" ? ["arn:aws:iam::${var.aws_account_ids["delius-core-non-prod"]}:role/dlc-dev-server-provision-ec2-role"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-pre-prod"]}:role/del-pre-prod-server-provision-ec2-role"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-stage"]}:role/del-stage-server-provision-ec2-role"]:[])
    }
    actions = ["kms:CreateGrants","kms:ListGrants","kms:RevokeGrant"]
    resources = ["*"]
    condition {
         test = "Bool"
         variable = "kms:GrantIsForAWSResource"
         values = [true]
    }
  } 



}