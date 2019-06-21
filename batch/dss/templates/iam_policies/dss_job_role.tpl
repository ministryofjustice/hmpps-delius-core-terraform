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
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/dss_user",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/dss_user_password",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/dss/dss/pnomis_web_password",
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/dss/dss/pnomis_web_user",
          "arn:aws:kms:${region}:${aws_account_id}:alias/aws/ssm"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParametersByPath"
      ],
      "Resource": [
          "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/dss"
      ]
    }

  ]
}