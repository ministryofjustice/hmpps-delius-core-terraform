{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
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
    }
  ]
}