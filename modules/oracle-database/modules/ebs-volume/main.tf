resource "aws_ebs_volume" "oracle_db" {
  count             = "${var.create_volume ? 1 : 0}"
  availability_zone = "${var.availability_zone}"
  type              = "io1"
  iops              = "${var.iops}"
  size              = "${var.size}"
  encrypted         = "${var.encrypted}"
  kms_key_id        = "${var.kms_key_id}"
  tags              = "${var.tags}"
}

resource "aws_volume_attachment" "oracle_db" {
  count        = "${var.create_volume ? 1 : 0}"
  device_name  = "${var.device_name}"
  instance_id  = "${var.instance_id}"
  volume_id    = "${element(aws_ebs_volume.oracle_db.*.id, count.index)}"
  force_detach = true
}
