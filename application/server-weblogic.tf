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

resource "aws_volume_attachment" "weblogic-xvdc" {
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

resource "aws_lb" "weblogic-lb" {
  internal        = false
  ip_address_type = "ipv4"
  security_groups = ["${data.aws_security_group.elb.id}"]
  subnets         = ["${data.aws_subnet_ids.public.ids}"]
}

resource "aws_lb_target_group" "weblogic-lb-target-group" {
  port     = 9704
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "weblogic-lb-target-group-attach" {
  port             = 9704
  target_group_arn = "${aws_lb_target_group.weblogic-lb-target-group.arn}"
  target_id        = "${aws_instance.weblogic.id}"
}

resource "aws_lb_listener" "weblogic-lb-listener" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.weblogic-lb-target-group.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.weblogic-lb.arn}"
  port              = 9704
}

resource "aws_route53_record" "weblogic-lb" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "www"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.weblogic-lb.dns_name}"]
}
