resource "aws_instance" "db" {
  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.instance_type_db}"
  subnet_id                   = "${data.aws_subnet.public_a.id}"
  key_name                    = "${local.environment_name}"
  associate_public_ip_address = true
  source_dest_check           = false

  vpc_security_group_ids = [
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.db_in.id}",
  ]

  root_block_device = {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${local.environment_name}-db"))}"
}

resource "aws_ebs_volume" "db_xvdc" {
  availability_zone = "${aws_instance.db.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${data.aws_kms_key.master.arn}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-db-xvdc"))}"
}

resource "aws_volume_attachment" "db_xvdc" {
  device_name = "/dev/xvdc"
  instance_id = "${aws_instance.db.id}"
  volume_id   = "${aws_ebs_volume.db_xvdc.id}"
}
