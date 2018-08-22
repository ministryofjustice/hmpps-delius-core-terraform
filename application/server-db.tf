resource "aws_instance" "delius_db" {
  ami               = "${data.aws_ami.centos.id}"
  instance_type     = "${var.instance_type_db}"
  subnet_id         = "${element(data.aws_subnet_ids.private.ids, 0)}"
  key_name          = "${local.environment_name}"
  source_dest_check = false

  vpc_security_group_ids = [
    "${data.aws_security_group.ssh_bastion_in.id}",
    "${data.aws_security_group.delius_db_in}",
  ]

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${local.environment_name}-delius-db"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }

}

resource "aws_ebs_volume" "delius_db_xvdc" {
  availability_zone = "${aws_instance.delius_db.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${data.aws_kms_key.master.arn}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-db-xvdc"))}"
}

resource "aws_volume_attachment" "delius_db_xvdc" {
  device_name  = "/dev/xvdc"
  instance_id  = "${aws_instance.delius_db.id}"
  volume_id    = "${aws_ebs_volume.db_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "delius_db" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "db"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.delius_db.private_ip}"]
}
