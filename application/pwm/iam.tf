# Attach a policy to the task role, to allow the container to pull config from S3
resource "aws_iam_policy" "task_policy" {
  name   = "${var.environment_name}-${local.app_name}-ecs-task-policy"
  policy = "${data.template_file.task_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  role       = "${module.service.task_role["name"]}"
  policy_arn = "${aws_iam_policy.task_policy.arn}"
}