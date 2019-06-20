# EC2 role

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.role_name}"
  role = "${aws_iam_role.ec2.name}"
}

resource "aws_iam_role" "ec2" {
  name               = "${var.role_name}"
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = "${file("${path.module}/policies/ec2_assume_role_policy.json")}"
}

data "template_file" "bucket_access_policy" {
  template = "${file("${path.module}/policies/bucket_access_policy_template.json")}"

  vars {
    dependencies_bucket_arn = "${var.dependencies_bucket_arn}"
    s3_oracledb_backups_arn = "${var.s3_oracledb_backups_arn}"
    s3_ldap_backups_arn     = "${var.s3_ldap_backups_arn}"
    migration_bucket_arn    = "${var.migration_bucket_arn}"
  }
}

resource "aws_iam_policy" "delius_core_dependencies_bucket_access" {
  name   = "${var.environment_name}-dependencies-bucket-access"
  policy = "${data.template_file.bucket_access_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "delius_core_dependencies_bucket_access" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.delius_core_dependencies_bucket_access.arn}"
}

data "template_file" "ssm_read_only_policy" {
  template = "${file("${path.module}/policies/ssm_read_only.json")}"
}

resource "aws_iam_policy" "delius_core_ssm_read_only" {
  name   = "${var.environment_name}-ssm-read-only"
  policy = "${data.template_file.ssm_read_only_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "delius_core_ssm_read_only" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.delius_core_ssm_read_only.arn}"
}

resource "aws_iam_role_policy_attachment" "container_registry" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "template_file" "cloudwatch_logs_policy" {
  template = "${file("${path.module}/policies/cloudwatch_logs.json")}"
}

resource "aws_iam_policy" "delius_core_cloudwatch_logs" {
  name   = "${var.environment_name}-cloudwatch-logs"
  policy = "${data.template_file.cloudwatch_logs_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "delius_core_cloudwatch_logs" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.delius_core_cloudwatch_logs.arn}"
}

resource "aws_iam_role_policy_attachment" "delius_core_ec2_read_only" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "template_file" "ec2_create_tags_policy" {
  template = "${file("${path.module}/policies/ec2_create_tags_policy.json")}"
}

resource "aws_iam_policy" "ec2_create_tags" {
  name   = "${var.environment_name}-ec2-create-tags"
  policy = "${data.template_file.ec2_create_tags_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "ec2_create_tags" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.ec2_create_tags.arn}"
}
