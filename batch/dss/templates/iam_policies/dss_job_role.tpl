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
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/dss_pnomis_user",
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/dss_pnomis_password",
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/dss_ndelius_user",
          "arn:aws:ssm:eu-west-2:${aws_account_id}:parameter/dss_ndelius_password",
          "arn:aws:kms:eu-west-2:${aws_account_id}:key/alias/dss_param_key"
      ]
    }
  ]
}