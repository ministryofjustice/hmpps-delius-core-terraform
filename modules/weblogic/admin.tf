# Admin server (TODO: ASG of one)

resource "aws_instance" "admin" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.admin_instance_type}"
  subnet_id              = "${var.private_subnet}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  source_dest_check      = false
  vpc_security_group_ids = ["${var.admin_security_groups}"]
  user_data              = "${data.template_file.user_data.rendered}"

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-admin"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "aws_ebs_volume" "admin_xvdc" {
  availability_zone = "${aws_instance.admin.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${var.kms_key_id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-admin-xvdc"))}"
}

resource "aws_volume_attachment" "admin_xvdc" {
  device_name  = "/dev/xvdc"
  instance_id  = "${aws_instance.admin.id}"
  volume_id    = "${aws_ebs_volume.admin_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "admin_instance_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-admin-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.admin.private_ip}"]
}

resource "aws_route53_record" "admin_instance_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-admin-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.admin.private_ip}"]
}

output "internal_fqdn_admin" {
  value = "${aws_route53_record.admin_instance_internal.fqdn}"
}

output "public_fqdn_admin" {
  value = "${aws_route53_record.admin_instance_public.fqdn}"
}

output "private_ip_admin" {
  value = "${aws_instance.admin.private_ip}"
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
  vpc_id   = "${var.vpc_id}"
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

resource "aws_route53_record" "admin_lb_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-admin"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.admin.dns_name}"]
}

resource "aws_route53_record" "admin_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-admin"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.admin.dns_name}"]
}

output "internal_fqdn_admin_lb" {
  value = "${aws_route53_record.admin_lb_internal.fqdn}"
}

output "public_fqdn_admin_lb" {
  value = "${aws_route53_record.admin_lb_public.fqdn}"
}
