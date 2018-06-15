resource "aws_instance" "weblogic" {
  count                       = 1
  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.instance_type_weblogic}"
  subnet_id                   = "${data.aws_subnet.public_a.id}"
  key_name                    = "${local.environment_name}"
  associate_public_ip_address = true
  source_dest_check           = false

  vpc_security_group_ids = [
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.egress_all.id}",
  ]

  root_block_device = {
    delete_on_termination = true
  }

  tags = "${merge(var.tags, map("Name", "${local.environment_name}-weblogic-${count.index}"))}"
}

resource "aws_ebs_volume" "weblogic" {
  availability_zone = "${aws_instance.weblogic.availability_zone}"
  type              = "gp2"
  size              = 100
  encrypted         = true
  kms_key_id        = "${data.aws_kms_key.master.arn}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-weblogic"))}"
}

resource "aws_volume_attachment" "weblogic" {
  device_name = "/dev/xvdb"
  instance_id = "${aws_instance.weblogic.id}"
  volume_id   = "${aws_ebs_volume.weblogic.id}"
}
