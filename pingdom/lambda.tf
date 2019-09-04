resource "random_uuid" "uuid" {}

data "template_file" "template" {
  template = "${file("${path.module}/templates/lambda/update-security-groups.py")}"
  vars {
    security_group_id = "${data.terraform_remote_state.delius_core_security_groups.sg_pingdom_in_id}"
    username          = "${var.pingdom_user}"
    password          = "${var.pingdom_password}"
    api_key           = "${var.pingdom_api_key}"
    account_email     = "${var.pingdom_account_email}"
  }
}

resource "local_file" "file" {
  filename   = "/tmp/${random_uuid.uuid.result}/index.py"
  content    = "${data.template_file.template.rendered}"
  depends_on = ["random_uuid.uuid"]
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = "/tmp/${random_uuid.uuid.result}"
  output_path = "/tmp/${random_uuid.uuid.result}/zip.zip"
  depends_on  = ["local_file.file"]
}

resource "aws_lambda_function" "function" {
  filename      = "/tmp/${random_uuid.uuid.result}/zip.zip"
  function_name = "${var.environment_name}-update-pingdom-cidr-ranges"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "index.lambda_handler"
  runtime       = "python2.7"
  publish       = true
  timeout       = 10
  tags          = "${merge(var.tags, map("Name", "${var.environment_name}-update-pingdom-cidr-ranges"))}"

  source_code_hash = "${data.archive_file.archive.output_base64sha256}"
  description      = "Update security groups to allow ingress from pingdom probe IPs"
  depends_on       = ["data.archive_file.archive"]
}