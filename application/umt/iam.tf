# Task execution role for pulling the image, fetching secrets, and pushing logs to cloudwatch
resource "aws_iam_role" "exec" {
  name               = "${var.environment_name}-${local.app_name}-ecs-exec-role"
  assume_role_policy = "${data.template_file.ecs_assume_role_policy_template.rendered}"
}

resource "aws_iam_policy" "exec_policy" {
  name   = "${var.environment_name}-${local.app_name}-ecs-exec-policy"
  policy = "${data.template_file.ecs_exec_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "exec_policy_attachment" {
  role       = "${aws_iam_role.exec.name}"
  policy_arn = "${aws_iam_policy.exec_policy.arn}"
}

# Task role for the task to interact with AWS services
resource "aws_iam_role" "task" {
  name               = "${var.environment_name}-${local.app_name}-ecs-task-role"
  assume_role_policy = "${data.template_file.ecs_assume_role_policy_template.rendered}"
}

# Instance role for the EC2 instances in the cluster
resource "aws_iam_role" "ecs_instance" {
  name               = "${var.environment_name}-${local.app_name}-ecs-instance-role"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = "${data.template_file.ec2_assume_role_policy_template.rendered}"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.environment_name}-${local.app_name}-ecs-instance-profile"
  role = "${aws_iam_role.ecs_instance.name}"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "auto_scaling" {
  role       = "${aws_iam_role.ecs_instance.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}