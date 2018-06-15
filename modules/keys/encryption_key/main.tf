resource "aws_kms_key" "kms" {
  description = "${var.key_name}"
  tags        = "${merge(var.tags, map("Name", var.key_name))}"
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${var.key_name}"
  target_key_id = "${aws_kms_key.kms.key_id}"
}
