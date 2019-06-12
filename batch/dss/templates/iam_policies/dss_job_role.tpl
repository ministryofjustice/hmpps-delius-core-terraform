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
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/${environment_name}/delius-core/dss/dss/dss_web_password",
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/${environment_name}/delius-core/dss/dss/dss_web_user",
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/${environment_name}/delius-core/dss/dss/pnomis_web_password",
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/${environment_name}/delius-core/dss/dss/pnomis_web_user",
          "arn:aws:kms:eu-west-2:${aws_account_id}:alias/aws/ssm"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParametersByPath"
      ],
      "Resource": [
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/${environment_name}/delius-core/dss"
      ]
    }

  ]
}