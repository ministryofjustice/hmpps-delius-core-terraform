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
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password",
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/delius-database/db/delius_app_schema_password",
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/umt/umt/jwt_secret",
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/umt/umt/delius_secret",
        "arn:aws:kms:${region}:${aws_account_id}:alias/aws/ssm"
      ]
    }
  ]
}