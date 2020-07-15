## For ease of maintenance outputs are close to resource creation.
locals {
  # data.aws_route53_zone.public.name returns with trailing period, so need to remove that.
  public_fqdn_length = "${length(data.aws_route53_zone.public.name) - 1}"
  public_fqdn        = "${substr(data.aws_route53_zone.public.name, 0, local.public_fqdn_length)}"

  # db_size_delius_core attribute may not be set in all envs, if not we default to two
  high_availability_count = "${lookup(var.db_size_delius_core, "high_availability_count", 2)}"
  empty                   = ""
  db1                     = "delius-db-1.${local.public_fqdn}"
  db2                     = "delius-db-2.${local.public_fqdn}"
  db3                     = "delius-db-3.${local.public_fqdn}"
  db1_add                 = "(ADDRESS=(PROTOCOL=tcp)(HOST=${local.db1})(PORT=1521))"
  db2_add                 = "(ADDRESS=(PROTOCOL=tcp)(HOST=${local.db2})(PORT=1521))"
  db3_add                 = "(ADDRESS=(PROTOCOL=tcp)(HOST=${local.db3})(PORT=1521))"
  db1_address             = "${local.db1_add}"
  db2_address             = "${local.high_availability_count >= 1 ? local.db2_add : local.empty}"
  db3_address             = "${local.high_availability_count >= 2 ? local.db3_add : local.empty}"
  address_list            = "${local.db1_address}${local.db2_address}${local.db3_address}"
}

output "jdbc_failover_url" {
  value = "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(FAILOVER=ON)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=${local.address_list})(CONNECT_DATA=(SERVICE_NAME=${var.ansible_vars_oracle_db["database_sid"]}_TAF)))"
}
