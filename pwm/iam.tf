data "template_file" "assume_role_policy_template" {
  template = "${file("${path.module}/templates/iam/ec2_assume_role_policy.json.tpl")}"
  vars {}
}

data "template_file" "get_params_policy_template" {
  template = "${file("${path.module}/templates/iam/pwm_get_parameters_role_policy.json.tpl")}"
  vars {
    aws_account_id   = "${data.aws_caller_identity.current.account_id}"
    environment_name = "${var.environment_name}"
    region           = "${var.region}"
    project_name     = "${var.project_name}"
  }
}

data "template_file" "cloudwatch_logs_policy_template" {
  template = "${file("${path.module}/templates/iam/cloudwatch_logs_role_policy.json.tpl")}"
  vars {
    aws_account_id = "${data.aws_caller_identity.current.account_id}"
    region         = "${var.region}"
  }
}


resource "aws_iam_role" "ecs" {
  name               = "${var.environment_name}-pwm-ecs-role"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = "${data.template_file.assume_role_policy_template.rendered}"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.environment_name}-pwm-ecs-instance-profile"
  role = "${aws_iam_role.ecs.name}"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy" "get_params" {
  name   = "${var.environment_name}-pwm-get-params"
  policy = "${data.template_file.get_params_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "get_params" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "${aws_iam_policy.get_params.arn}"
}

resource "aws_iam_policy" "cloudwatch_logs" {
  name   = "${var.environment_name}-pwm-cloudwatch-logs"
  policy = "${data.template_file.cloudwatch_logs_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = "${aws_iam_role.ecs.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_logs.arn}"
}