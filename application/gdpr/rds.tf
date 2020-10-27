resource "random_password" "db_password" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "db_password_parameter" {
  name  = "/${var.environment_name}/${var.project_name}/delius-gdpr-database/db/admin_password"
  value = random_password.db_password.result
  type  = "SecureString"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.environment_name}-${local.app_name}-db-subnet-group"
  subnet_ids = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "primary" {
  identifier     = "${var.environment_name}-${local.app_name}-primary-db"
  engine         = "postgres"
  engine_version = "11.5"
  instance_class = local.gdpr_config["db_instance_class"]

  allocated_storage = local.gdpr_config["db_storage"]
  storage_encrypted = true

  name     = "gdpr"
  username = "postgres"
  password = aws_ssm_parameter.db_password_parameter.value

  vpc_security_group_ids = [
    data.terraform_remote_state.delius_core_security_groups.outputs.sg_gdpr_db_id
  ]

  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  multi_az            = true
  publicly_accessible = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = var.environment_name != "delius-prod"

  maintenance_window        = local.gdpr_config["db_maintenance_window"]
  backup_retention_period   = local.gdpr_config["db_backup_retention_period"]
  backup_window             = local.gdpr_config["db_backup_window"]
  final_snapshot_identifier = "${var.environment_name}-final-snapshot"

  tags = merge(var.tags, { Name = "${local.app_name}-primary-db" })

  lifecycle {
    ignore_changes = [engine_version] # Allow automated minor version upgrades
  }
}

