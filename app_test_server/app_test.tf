resource "aws_instance" "app_test" {
  ami                  = "${data.aws_ami.centos.id}"
  instance_type        = "t2.micro"
  subnet_id            = "${data.aws_subnet.private_a.id}"
  key_name             = "${local.environment_name}"
  source_dest_check    = false
  user_data            = "${file("install_tools.sh")}"
  iam_instance_profile = "${local.environment_name}-server-provison-ec2-role"

  vpc_security_group_ids = [
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
  ]

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${local.environment_name}-app-test"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "aws_route53_record" "app_test" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "app_test"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.app_test.private_ip}"]
}
