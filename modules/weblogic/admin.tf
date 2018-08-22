# Admin server (TODO: ASG of one)

resource "aws_instance" "admin" {
  ami               = "${data.aws_ami.centos.id}"
  instance_type     = "${var.admin_instance_type}"
  subnet_id         = "${var.private_subnet}"
  key_name          = "${var.environment_name}"
  source_dest_check = false

  vpc_security_group_ids = ["${var.admin_security_groups}"]

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-admin"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "aws_ebs_volume" "admin_xvdc" {
  availability_zone = "${aws_instance.admin.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${data.aws_kms_key.master.arn}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}-weblogic-xvdc"))}"
}

resource "aws_volume_attachment" "admin_xvdc" {
  device_name  = "/dev/xvdc"
  instance_id  = "${aws_instance.admin.id}"
  volume_id    = "${aws_ebs_volume.admin_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "admin_instance" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.tier_name}-admin-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.admin.private_ip}"]
}

# Managed ELB

resource "aws_lb" "admin" {
  internal        = false
  ip_address_type = "ipv4"
  security_groups = ["${var.admin_elb_sg_id}"]
  subnets         = ["${var.public_subnets}"]
}

resource "aws_lb_target_group" "admin" {
  port     = "${var.admin_port}"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc.id}"
}

resource "aws_lb_target_group_attachment" "admin" {
  port             = "${var.admin_port}"
  target_group_arn = "${aws_lb_target_group.admin.arn}"
  target_id        = "${aws_instance.admin.id}"
}

resource "aws_lb_listener" "admin" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.admin.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.admin.arn}"
  port              = "${var.admin_port}"
}

resource "aws_route53_record" "admin_lb" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.tier_name}-admin"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.admin.dns_name}"]
}
