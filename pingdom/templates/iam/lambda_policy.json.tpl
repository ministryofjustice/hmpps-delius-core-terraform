{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:${region}:${eng_account_id}:parameter/engineering-dev/engineering/pingdom/admin/username",
        "arn:aws:ssm:${region}:${eng_account_id}:parameter/engineering-dev/engineering/pingdom/admin/password",
        "arn:aws:ssm:${region}:${eng_account_id}:parameter/engineering-dev/engineering/pingdom/admin/api_key",
        "arn:aws:ssm:${region}:${eng_account_id}:parameter/engineering-dev/engineering/pingdom/admin/account_email"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": [
        "arn:aws:ec2:${region}:${current_account_id}:security-group/${security_group_id}"
      ]
    }
  ]
}