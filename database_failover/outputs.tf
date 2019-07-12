## For ease of maintenance outputs are close to resource creation.

output "jdbc_failover_url" {
  value = "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(FAILOVER=ON)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=${module.delius_db_1.public_fqdn})(PORT=1521))(ADDRESS=(PROTOCOL=tcp)(HOST=${module.delius_db_2.public_fqdn})(PORT=1521))(ADDRESS=(PROTOCOL=tcp)(HOST=${module.delius_db_3.public_fqdn})(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=${var.ansible_vars_oracle_db["database_sid"]}_TAF)))"
}