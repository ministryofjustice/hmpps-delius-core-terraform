data "aws_caller_identity" "current" {}

data "template_file" "ecs_assume_role_policy_template" {
  template = "${file("${path.module}/templates/iam/ecs_assume_role_policy.json.tpl")}"
  vars {}
}

data "template_file" "ecs_exec_policy_template" {
  template = "${file("${path.module}/templates/iam/ecs_exec_policy.json.tpl")}"
  vars {
    aws_account_id          = "${data.aws_caller_identity.current.account_id}"
    region                  = "${var.region}"
    environment_name        = "${var.environment_name}"
    project_name            = "${var.project_name}"
    required_ssm_parameters = "${jsonencode(var.required_ssm_parameters)}"
  }
}
