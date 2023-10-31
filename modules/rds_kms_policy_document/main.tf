data "aws_iam_policy_document" "rds_kms_policy_document" {
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
                     var.environment_name == "delius-test" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-mis-dev"]}:role/terraform"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-pre-prod"]}:role/terraform"]:[],
                     var.environment_name == "delius-prod" ? ["arn:aws:iam::${var.aws_account_ids["hmpps-delius-stage"]}:role/terraform"]:[])
    }
    actions = ["kms:CreateGrant","kms:DescribeKey"]
    resources = ["*"]
  }

}