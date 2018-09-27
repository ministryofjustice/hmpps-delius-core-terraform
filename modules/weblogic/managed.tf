# Managed server (TODO: ASG)

resource "aws_instance" "managed" {
  ami                  = "${var.ami_id}"
  instance_type        = "${var.managed_instance_type}"
  subnet_id            = "${var.private_subnet}"
  key_name             = "${var.key_name}"
  iam_instance_profile = "${var.iam_instance_profile}"
  source_dest_check    = false

  vpc_security_group_ids = ["${var.managed_security_groups}"]

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-managed"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "aws_ebs_volume" "managed_xvdc" {
  availability_zone = "${aws_instance.managed.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${var.kms_key_id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-managed-xvdc"))}"
}

resource "aws_volume_attachment" "managed_xvdc" {
  device_name  = "/dev/xvdc"
  instance_id  = "${aws_instance.managed.id}"
  volume_id    = "${aws_ebs_volume.managed_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "managed_instance_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-managed-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.managed.private_ip}"]
}

resource "aws_route53_record" "managed_instance_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-managed-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.managed.private_ip}"]
}

output "internal_fqdn_managed" {
  value = "${aws_route53_record.managed_instance_internal.fqdn}"
}

output "public_fqdn_managed" {
  value = "${aws_route53_record.managed_instance_public.fqdn}"
}

output "private_ip_managed" {
  value = "${aws_instance.managed.private_ip}"
}

# Managed ELB

resource "aws_lb" "managed" {
  internal        = false
  ip_address_type = "ipv4"
  security_groups = ["${var.managed_elb_sg_id}"]
  subnets         = ["${var.public_subnets}"]
}

resource "aws_lb_target_group" "managed" {
  port     = "${var.managed_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb_target_group_attachment" "managed" {
  port             = "${var.managed_port}"
  target_group_arn = "${aws_lb_target_group.managed.arn}"
  target_id        = "${aws_instance.managed.id}"
}

resource "aws_lb_listener" "managed" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.managed.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.managed.arn}"
  port              = "${var.managed_port}"
}

resource "aws_route53_record" "managed_lb_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-managed"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.managed.dns_name}"]
}

resource "aws_route53_record" "managed_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-managed"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.managed.dns_name}"]
}

output "internal_fqdn_managed_lb" {
  value = "${aws_route53_record.managed_lb_internal.fqdn}"
}

output "public_fqdn_managed_lb" {
  value = "${aws_route53_record.managed_lb_public.fqdn}"
}
