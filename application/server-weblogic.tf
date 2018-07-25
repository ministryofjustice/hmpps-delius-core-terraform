resource "aws_instance" "weblogic" {
  ami               = "${data.aws_ami.centos.id}"
  instance_type     = "${var.instance_type_weblogic}"
  subnet_id         = "${data.aws_subnet.private_a.id}"
  key_name          = "${local.environment_name}"
  source_dest_check = false

  vpc_security_group_ids = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${local.environment_name}-weblogic"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "aws_ebs_volume" "weblogic_xvdc" {
  availability_zone = "${aws_instance.weblogic.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${data.aws_kms_key.master.arn}"
  tags              = "${merge(var.tags, map("Name", "${local.environment_name}-weblogic-xvdc"))}"
}

resource "aws_volume_attachment" "weblogic_xvdc" {
  device_name  = "/dev/xvdc"
  instance_id  = "${aws_instance.weblogic.id}"
  volume_id    = "${aws_ebs_volume.weblogic_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "weblogic" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "weblogic"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.weblogic.private_ip}"]
}