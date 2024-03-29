## For ease of maintenance outputs are close to resource creation.
locals {
  public_fqdn = data.aws_route53_zone.public.name

  # db_size_delius_core attribute may not be set in all envs, if not we default to two
  high_availability_count = var.database_high_availability_count["delius"]
  empty                   = ""
  db1                     = "delius-db-1.${local.public_fqdn}"
  db2                     = "delius-db-2.${local.public_fqdn}"
  db3                     = "delius-db-3.${local.public_fqdn}"
  db1_add                 = "(ADDRESS=(PROTOCOL=tcp)(HOST=${local.db1})(PORT=1521))"
  db2_add                 = "(ADDRESS=(PROTOCOL=tcp)(HOST=${local.db2})(PORT=1521))"
  db3_add                 = "(ADDRESS=(PROTOCOL=tcp)(HOST=${local.db3})(PORT=1521))"
  db1_address             = local.db1_add
  db2_address             = local.high_availability_count >= 1 ? local.db2_add : local.empty
  db3_address             = local.high_availability_count >= 2 ? local.db3_add : local.empty
  address_list            = "${local.db1_address}${local.db2_address}${local.db3_address}"
}

output "jdbc_failover_url" {
  value = "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(FAILOVER=ON)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=${local.address_list})(CONNECT_DATA=(SERVICE_NAME=${var.ansible_vars_oracle_db["database_sid"]}_TAF)))"
}

output "jdbc_standby_url" {
  value = local.high_availability_count >= 2 ? "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=${local.db3_add})(CONNECT_DATA=(SERVICE_NAME=${var.ansible_vars_oracle_db["database_sid"]}S2)))" : (
          local.high_availability_count >= 1 ? "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=${local.db2_add})(CONNECT_DATA=(SERVICE_NAME=${var.ansible_vars_oracle_db["database_sid"]}S1)))"
                                             : "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=${local.db1_add})(CONNECT_DATA=(SERVICE_NAME=${var.ansible_vars_oracle_db["database_sid"]}_TAF)))")
}

output "tns_delius_primarydb" {
  value = "${var.ansible_vars_oracle_db["database_sid"]} = (DESCRIPTION = ${local.db1_add}(CONNECT_DATA = (SERVER=DEDICATED)(SERVICE_NAME = ${var.ansible_vars_oracle_db["database_sid"]})))"
}
output "tns_delius_standbydb1" {
  value = "${var.ansible_vars_oracle_db["database_sid"]}S1 = (DESCRIPTION = ${local.db2_add}(CONNECT_DATA = (SERVER=DEDICATED)(SERVICE_NAME = ${var.ansible_vars_oracle_db["database_sid"]}S1)))"
}
output "tns_delius_standbydb2" {
  value = "${var.ansible_vars_oracle_db["database_sid"]}S2 = (DESCRIPTION = ${local.db3_add}(CONNECT_DATA = (SERVER=DEDICATED)(SERVICE_NAME = ${var.ansible_vars_oracle_db["database_sid"]}S2)))"
}

output "bastion_inventory" {
   value = var.bastion_inventory
}

output "database_name" {
   value = var.ansible_vars_oracle_db["database_sid"]
}

locals {
   source_server_map = {
    "delius_primarydb"  = local.db1
    "delius_standbydb1" = local.db2
    "delius_standbydb2" = local.db3
   }
   source_database_map = {
    "delius_primarydb"  = var.ansible_vars_oracle_db["database_sid"]
    "delius_standbydb1" = "${var.ansible_vars_oracle_db["database_sid"]}S1"
    "delius_standbydb2" = "${var.ansible_vars_oracle_db["database_sid"]}S2"
   }
}

# Reading from the database endpoint may optionally done on the standby
# Writing must always be done on the primary
output "dms_endpoint_details" {
   value = {
    database_server_for_reads   = local.source_server_map[var.oracle_audited_interaction.source_server]
    database_port_for_reads     = "1522"
    database_name_for_reads     = local.source_database_map[var.oracle_audited_interaction.source_server]
    database_server_for_writes  = local.source_server_map["delius_primarydb"]
    database_port_for_writes    = "1522"
    database_name_for_writes    = local.source_database_map["delius_primarydb"]
    bastion_inventory  = var.bastion_inventory
    password_path      = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_audit_dms_pool_password"
    target_environment = var.oracle_audited_interaction.target_environment
   }

}