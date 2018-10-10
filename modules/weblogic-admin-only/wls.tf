# Admin server (TODO: ASG of one)

resource "aws_instance" "wls" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id              = "${var.private_subnet}"
  user_data              = "${data.template_file.user_data.rendered}"
  source_dest_check      = false

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-wls"))}"

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

resource "aws_ebs_volume" "wls_xvdc" {
  availability_zone = "${aws_instance.wls.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${var.kms_key_id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-wls-xvdc"))}"
}

resource "aws_volume_attachment" "wls_xvdc" {
  device_name  = "${var.device_name}"
  instance_id  = "${aws_instance.wls.id}"
  volume_id    = "${aws_ebs_volume.wls_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "wls_instance_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-wls-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.wls.private_ip}"]
}

resource "aws_route53_record" "wls_instance_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-wls-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.wls.private_ip}"]
}

output "internal_fqdn_wls" {
  value = "${aws_route53_record.wls_instance_internal.fqdn}"
}

output "public_fqdn_wls" {
  value = "${aws_route53_record.wls_instance_public.fqdn}"
}

output "private_ip_wls" {
  value = "${aws_instance.wls.private_ip}"
}

# Managed ELB

resource "aws_lb" "wls" {
  internal        = false
  ip_address_type = "ipv4"
  security_groups = ["${var.admin_elb_sg_id}"]
  subnets         = ["${var.public_subnets}"]
  tags            = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-wls"))}"
}

resource "aws_lb_target_group" "wls" {
  port     = "${var.admin_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  tags     = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-wls"))}"
}

resource "aws_lb_target_group_attachment" "wls" {
  port             = "${var.admin_port}"
  target_group_arn = "${aws_lb_target_group.wls.arn}"
  target_id        = "${aws_instance.wls.id}"
}

resource "aws_lb_listener" "wls" {
  "default_action" {
    target_group_arn = "${aws_lb_target_group.wls.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.wls.arn}"
  port              = "${var.admin_port}"
}

resource "aws_route53_record" "wls_lb_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-wls"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.wls.dns_name}"]
}

resource "aws_route53_record" "wls_lb_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-wls"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.wls.dns_name}"]
}

output "internal_fqdn_wls_lb" {
  value = "${aws_route53_record.wls_lb_internal.fqdn}"
}

output "public_fqdn_wls_lb" {
  value = "${aws_route53_record.wls_lb_public.fqdn}"
}
