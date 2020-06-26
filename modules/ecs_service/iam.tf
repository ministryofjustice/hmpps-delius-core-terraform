# Task execution role for pulling the image, fetching secrets, and pushing logs to cloudwatch
resource "aws_iam_role" "exec" {
  name               = "${var.environment_name}-${var.service_name}-ecs-exec-role"
  assume_role_policy = "${data.template_file.ecs_assume_role_policy_template.rendered}"
}

resource "aws_iam_policy" "exec_policy" {
  name   = "${var.environment_name}-${var.service_name}-ecs-exec-policy"
  policy = "${data.template_file.ecs_exec_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "exec_policy_attachment" {
  role       = "${aws_iam_role.exec.name}"
  policy_arn = "${aws_iam_policy.exec_policy.arn}"
}

# Task role for the task to interact with AWS services
resource "aws_iam_role" "task" {
  name               = "${var.environment_name}-${var.service_name}-ecs-task-role"
  assume_role_policy = "${data.template_file.ecs_assume_role_policy_template.rendered}"
}
