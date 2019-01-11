# Admin server (TODO: ASG of one)

resource "aws_instance" "ldap" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id              = "${var.private_subnets[0]}"
  user_data              = "${data.template_file.user_data.rendered}"
  source_dest_check      = false

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-ldap"))}"

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

resource "aws_instance" "ldap_slave" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id              = "${var.private_subnets[0]}"
  user_data              = "${data.template_file.user_data_slave.rendered}"
  source_dest_check      = false

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${var.tier_name}-ldap-slave"))}"

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

resource "aws_route53_record" "ldap_instance_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ldap.private_ip}"]
}

resource "aws_route53_record" "ldap_instance_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ldap.private_ip}"]
}

resource "aws_route53_record" "ldap_slave_instance_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.tier_name}-slave-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ldap_slave.private_ip}"]
}

resource "aws_route53_record" "ldap_slave_instance_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.tier_name}-slave-instance"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.ldap_slave.private_ip}"]
}

output "internal_fqdn_ldap" {
  value = "${aws_route53_record.ldap_instance_internal.fqdn}"
}

output "public_fqdn_ldap" {
  value = "${aws_route53_record.ldap_instance_public.fqdn}"
}

output "private_ip_ldap" {
  value = "${aws_instance.ldap.private_ip}"
}
