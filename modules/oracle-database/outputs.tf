output "public_fqdn" {
  value = "${aws_route53_record.oracle_db_instance_public.fqdn}"
}

output "internal_fqdn" {
  value = "${aws_route53_record.oracle_db_instance_internal.fqdn}"
}

output "private_ip" {
  value = "${aws_instance.oracle_db.private_ip}"
}

output "ami_id" {
  value = "${aws_instance.oracle_db.id}"
}

output "db_size_parameters" {
  value = {
    database_size  = "${local.database_size}"
    iops           = "${local.iops}"
    disks_quantity = "${local.disks_quantity}"
    size           = "${local.size}"
    total_storage  = "${local.disks_quantity*local.size}"
    iops_ratio     = "${local.iops/local.size} (50 max)"
  }
}
