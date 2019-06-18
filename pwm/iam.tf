resource "aws_iam_role" "ecs" {
  name               = "${var.environment_name}-pwm-ecs-role"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = "${file("${path.module}/policies/ec2_assume_role_policy.json")}"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.environment_name}-pwm-ecs-instance-profile"
  role = "${aws_iam_role.ecs.name}"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}