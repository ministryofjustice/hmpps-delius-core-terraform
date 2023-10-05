# Password to use for DMS Endpoints connecting to this database for Audit data Preservation migrations
 # prefix not to contain any special characters
 resource "random_string" "prefix" {
   length    = 4
   upper     = true
   min_upper = 1
   lower     = true
   min_lower = 1
   numeric   = false
   special   = false
 }

 # random string for remainder of password
 resource "random_string" "remainder" {
   length           = 11
   special          = true
   override_special = "#_"
 }

 resource "aws_ssm_parameter" "delius_audit_dms_pool_password" {
   name  = "/${var.environment_name}/${var.project_name}/delius-database/db/delius_audit_dms_pool_password"
   value = "${random_string.prefix.result}${random_string.remainder.result}"
   type  = "SecureString"
   lifecycle {
     ignore_changes = [value]
   }
 }