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
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/pwm/pwm/security_key",
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/pwm/pwm/config_password",
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password",
        "arn:aws:kms:${region}:${aws_account_id}:alias/aws/ssm"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParametersByPath"
      ],
      "Resource": [
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/pwm",
        "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds"
      ]
    }
  ]
}