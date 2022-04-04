# EC2 role

resource "aws_iam_instance_profile" "ec2" {
  name = var.role_name
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "ec2" {
  name               = var.role_name
  description        = "Allows EC2 instances to call AWS services on your behalf."
  assume_role_policy = file("${path.module}/policies/ec2_assume_role_policy.json")
}

data "template_file" "bucket_access_policy" {
  template = file("${path.module}/policies/bucket_access_policy_template.json")

  vars = {
    dependencies_bucket_arn = var.dependencies_bucket_arn
    s3_oracledb_backups_arn = var.s3_oracledb_backups_arn
    s3_oracledb_backups_inventory_arn = var.s3_oracledb_backups_inventory_arn
    s3_ldap_backups_arn     = var.s3_ldap_backups_arn
    s3_test_results_arn     = var.s3_test_results_arn
    s3_ssm_ansible_arn      = var.s3_ssm_ansible_arn
    migration_bucket_arn    = var.migration_bucket_arn
  }
}

resource "aws_iam_policy" "delius_core_dependencies_bucket_access" {
  name   = "${var.environment_name}-dependencies-bucket-access"
  policy = data.template_file.bucket_access_policy.rendered
}

resource "aws_iam_role_policy_attachment" "delius_core_dependencies_bucket_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.delius_core_dependencies_bucket_access.arn
}

data "template_file" "ssm_read_only_policy" {
  template = file("${path.module}/policies/ssm_read_only.json")
}

resource "aws_iam_policy" "delius_core_ssm_read_only" {
  name   = "${var.environment_name}-ssm-read-only"
  policy = data.template_file.ssm_read_only_policy.rendered
}

resource "aws_iam_role_policy_attachment" "delius_core_ssm_read_only" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.delius_core_ssm_read_only.arn
}

resource "aws_iam_role_policy_attachment" "container_registry" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "delius_core_ec2_read_only" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "template_file" "ec2_create_tags_policy" {
  template = file("${path.module}/policies/ec2_create_tags_policy.json")
}

resource "aws_iam_policy" "ec2_create_tags" {
  name   = "${var.environment_name}-ec2-create-tags"
  policy = data.template_file.ec2_create_tags_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ec2_create_tags" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_create_tags.arn
}

resource "aws_iam_role_policy_attachment" "ssm_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "template_file" "ssm_update_policy" {
  template = file("${path.module}/policies/ssm_update.json")
}

resource "aws_iam_policy" "delius_core_ssm_update" {
  name   = "${var.environment_name}-ssm-update"
  policy = data.template_file.ssm_update_policy.rendered
}

resource "aws_iam_role_policy_attachment" "delius_core_ssm_update" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.delius_core_ssm_update.arn
}
