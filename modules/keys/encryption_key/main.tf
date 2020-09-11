locals {
  aws_account = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {
}

resource "aws_kms_key" "kms" {
  description = var.key_name
  tags = merge(
    var.tags,
    {
      "Name" = var.key_name
    },
  )
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "key-default-1",
  "Statement": [
  {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {"AWS": [
          "arn:aws:iam::${local.aws_account}:root",
          "arn:aws:iam::${local.aws_account}:role/${var.environment_name}-start-ec2-phase1-scheduler-lambda",
          "arn:aws:iam::${local.aws_account}:role/${var.environment_name}-start-ec2-phase2-scheduler-lambda"
        ]},
        "Action": "kms:*",
        "Resource": "*"
     }
    ]
   }
  
POLICY

}

resource "aws_kms_alias" "kms" {
  name          = "alias/${var.key_name}"
  target_key_id = aws_kms_key.kms.key_id
}

