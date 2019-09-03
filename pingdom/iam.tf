data "template_file" "assume_role_policy_template" {
  template = "${file("${path.module}/templates/iam/assume_role_policy.json.tpl")}"
}

resource "aws_iam_role" "lambda" {
  name               = "${var.environment_name}-pingdom-lambda-role"
  description        = "Allows lambda function to call AWS services on your behalf."
  assume_role_policy = "${data.template_file.assume_role_policy_template.rendered}"
}

data "template_file" "lambda_policy_template" {
  template = "${file("${path.module}/templates/iam/lambda_policy.json.tpl")}"
  vars {
    region              = "${var.region}"
    eng_account_id      = "${var.eng_account_id}"
    current_account_id  = "${data.aws_caller_identity.current.account_id}"
    security_group_id   = "${data.terraform_remote_state.delius_core_security_groups.sg_pingdom_in_id}"
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.environment_name}-pingdom-lambda-policy"
  policy = "${data.template_file.lambda_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}