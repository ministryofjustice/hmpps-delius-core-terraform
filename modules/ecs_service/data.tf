data "aws_caller_identity" "current" {}

data "template_file" "ecs_assume_role_policy_template" {
  template = "${file("${path.module}/templates/iam/ecs_assume_role_policy.json.tpl")}"
  vars     = {}
}

data "template_file" "ssm_policy_statement_template" {
  template = <<EOF
    {
      "Effect": "Allow",
      "Action": ["ssm:GetParameter","ssm:GetParameters"],
      "Resource": $${allowed_ssm_parameters}
    },
    {
      "Effect": "Allow",
      "Action": ["kms:Decrypt"],
      "Resource": ["arn:aws:kms:$${region}:$${aws_account_id}:alias/aws/ssm"]
    },
EOF

  vars {
    aws_account_id         = "${data.aws_caller_identity.current.account_id}"
    region                 = "${var.region}"
    allowed_ssm_parameters = "${jsonencode(var.allowed_ssm_parameters)}"
  }
}

data "template_file" "ecs_exec_policy_template" {
  template = "${file("${path.module}/templates/iam/ecs_exec_policy.json.tpl")}"

  vars {
    aws_account_id = "${data.aws_caller_identity.current.account_id}"
    region         = "${var.region}"
    ssm_statement  = "${length(var.allowed_ssm_parameters) == 0 ? "": data.template_file.ssm_policy_statement_template.rendered}"
  }
}
