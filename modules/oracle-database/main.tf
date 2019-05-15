data "template_file" "user_data" {
  template = "${file("${path.module}/user_data/user_data.sh")}"

  vars {
    env_identifier       = "${var.environment_identifier}"
    short_env_identifier = "${var.short_environment_identifier}"
    region               = "${var.region}"
    app_name             = "${var.server_name}"
    route53_sub_domain   = "${var.environment_name}"
    private_domain       = "${var.private_domain}"
    account_id           = "${var.vpc_account_id}"
    bastion_inventory    = "${var.bastion_inventory}"

    service_user_name             = "${var.ansible_vars["service_user_name"]}"
    database_global_database_name = "${var.ansible_vars["database_global_database_name"]}"
    database_sid                  = "${var.ansible_vars["database_sid"]}"
    database_characterset         = "${var.ansible_vars["database_characterset"]}"
    oracle_dbca_template_file     = "${var.ansible_vars["oracle_dbca_template_file"]}"
    database_type                 = "${lookup(var.ansible_vars, "database_type", "NOTSET")}"
    s3_oracledb_backups_arn       = "${lookup(var.ansible_vars, "s3_oracledb_backups_arn", "NOTSET")}"
    dependencies_bucket_arn       = "${lookup(var.ansible_vars, "dependencies_bucket_arn", "NOTSET")}"
    database_bootstrap_restore    = "${lookup(var.ansible_vars, "database_bootstrap_restore", "False")}"
    database_backup               = "${lookup(var.ansible_vars, "database_backup", "NOTSET")}"
    database_backup_sys_passwd    = "${lookup(var.ansible_vars, "database_backup_sys_passwd", "NOTSET")}"
    database_backup_location      = "${lookup(var.ansible_vars, "database_backup_location", "NOTSET")}"
    asm_disks_quantity            = "${lookup(var.db_size, "disks_quantity")}"
  }
}

locals {
  database_size    = "${lookup(var.db_size, "database_size")}"
  instance_type    = "${lookup(var.db_size, "instance_type")}"
  iops             = "${lookup(var.db_size, "disk_iops")}"
  disks_quantity   = "${lookup(var.db_size, "disks_quantity")}"
  size             = "${lookup(var.db_size, "disk_size")}"
  tags_name_prefix = "${var.environment_name}-${var.server_name}"
}
resource "aws_instance" "oracle_db" {
  ami                    = "${var.ami_id}"
  instance_type          = "${local.instance_type}"
  subnet_id              = "${var.db_subnet}"
  key_name               = "${var.key_name}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  source_dest_check      = false
  vpc_security_group_ids = ["${var.security_group_ids}"]
  user_data              = "${data.template_file.user_data.rendered}"

  root_block_device = {
    delete_on_termination = true
    volume_size           = 256
    volume_type           = "io1"
    iops                  = "1000"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}-${var.server_name}"))}"

  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }




}

resource "aws_route53_record" "oracle_db_instance_internal" {
  zone_id = "${var.private_zone_id}"
  name    = "${var.server_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.oracle_db.private_ip}"]
}

resource "aws_route53_record" "oracle_db_instance_public" {
  zone_id = "${var.public_zone_id}"
  name    = "${var.server_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.oracle_db.private_ip}"]
}
