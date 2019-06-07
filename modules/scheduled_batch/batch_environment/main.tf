# Create a Service Role for AWS Batch to run under - allows to 
data "template_file" "batch_assume_role_template" {
  template = "${file("${path.module}/templates/iam_policies/batch_assume_policy.tpl")}"

  vars {}
}

resource "aws_iam_role" "batch_service_role" {
  name = "${var.ce_name}-batch-role"

  assume_role_policy = "${data.template_file.batch_assume_role_template.rendered}"
}

# Use existing managed iam policy for ECS instances - May want to copy and manage this separately
resource "aws_iam_role_policy_attachment" "batch_service_role_policy_attachment" {
  role       = "${aws_iam_role.batch_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# Create the EC2 Instance role
data "template_file" "ec2_assume_role_template" {
  template = "${file("${path.module}/templates/iam_policies/ec2_assume_policy.tpl")}"

  vars {}
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.ce_name}-ecs-role"

  assume_role_policy = "${data.template_file.ec2_assume_role_template.rendered}"
}

# Use existing managed iam policy for ECS instances - May want to copy and manage this separately
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachement" {
  role       = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_role"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_batch_compute_environment" "batch_ce" {
  compute_environment_name = "${var.ce_name}-ce"

  compute_resources {
    instance_role = "${aws_iam_instance_profile.ecs_instance_profile.arn}"

    instance_type = "${var.ce_instances}"

    max_vcpus = "${var.ce_max_vcpu}"
    min_vcpus = "${var.ce_min_vcpu}"

    security_group_ids = [ "${var.ce_sg}" ]

    subnets = [ "${var.ce_subnets}" ]

    type = "EC2"

    tags = "${var.ce_tags}"
  }

  service_role = "${aws_iam_role.batch_service_role.arn}"
  type         = "MANAGED"
  depends_on   = ["aws_iam_role_policy_attachment.batch_service_role_policy_attachment"]

  # AWS Batch manages the desired_vcpus value dynamically - don't try and adjust
  lifecycle {
    ignore_changes = [
      "compute_resources.0.desired_vcpus",
    ]
  }
}

resource "aws_batch_job_queue" "batch_queue" {
  name  = "${var.ce_name}-queue"
  state = "${var.ce_queue_state}"

  # This is a standalone CE with a single queue - therefore priority is fixed
  priority             = 1
  compute_environments = ["${aws_batch_compute_environment.batch_ce.arn}"]
}
