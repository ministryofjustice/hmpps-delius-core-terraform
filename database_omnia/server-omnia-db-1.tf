resource "aws_instance" "omnia_db" {
  ami                    = local.ami_id
  instance_type          = local.instance_type
  subnet_id              = local.db_subnet
  key_name               = local.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2.id
  source_dest_check      = false
  vpc_security_group_ids = local.security_group_ids
  user_data              = data.template_file.user_data.rendered

  root_block_device {
    delete_on_termination = true
    volume_size           = 256
    volume_type           = "io1"
    iops                  = "1000"
  }

  tags = merge({
    Name          = "${var.environment_name}-${local.server_name}"
    InventoryHost = "${var.environment_name}-${local.server_name}"
    Database      = local.server_name
  }, var.tags)

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}

resource "aws_route53_record" "omnia_db_instance_internal" {
  zone_id = local.private_zone_id
  name    = local.server_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.omnia_db.private_ip]
}

resource "aws_route53_record" "omnia_db_instance_public" {
  zone_id = local.public_zone_id
  name    = local.server_name
  type    = "A"
  ttl     = "300"
  records = [aws_instance.omnia_db.private_ip]
}

# map (tidier)
output "omnia_db_1" {
  value = {
    ami_id        = aws_instance.omnia_db.ami
    public_fqdn   = aws_route53_record.omnia_db_instance_public.fqdn
    internal_fqdn = aws_route53_record.omnia_db_instance_internal.fqdn
    private_ip    = aws_instance.omnia_db.private_ip
    omnia_db_1   = "ssh ${aws_route53_record.omnia_db_instance_public.fqdn}"
  }
}
