module "delius_db_2" {
  source      = "git::https://github.com/ministryofjustice/hmpps-oracle-database.git?ref=master//modules//oracle-database"
  server_name = "delius-db-2"

  ami_id               = "${data.aws_ami.centos_oracle_db.id}"
  db_subnet            = "${data.terraform_remote_state.vpc.vpc_db-subnet-az2}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"

  security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_delius_db_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_delius_db_out_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
    "${data.terraform_remote_state.vpc_security_groups.sg_delius_core_db_in_from_mis_id}",
  ]

  tags                         = "${var.tags}"
  environment_name             = "${data.terraform_remote_state.vpc.environment_name}"
  bastion_inventory            = "${data.terraform_remote_state.vpc.bastion_inventory}"
  project_name                 = "${var.project_name}"
  environment_identifier       = "${var.environment_identifier}"
  short_environment_identifier = "${var.short_environment_identifier}"

  environment_type = "${var.environment_type}"
  region           = "${var.region}"

  kms_key_id      = "${data.terraform_remote_state.key_profile.kms_arn_app}"
  public_zone_id  = "${data.terraform_remote_state.vpc.public_zone_id}"
  private_zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
  private_domain  = "${data.terraform_remote_state.vpc.private_zone_name}"
  vpc_account_id  = "${data.terraform_remote_state.vpc.vpc_account_id}"
  db_size         = "${var.db_size_delius_core}"

  ansible_vars = {
    service_user_name             = "${var.ansible_vars_oracle_db["service_user_name"]}"
    database_global_database_name = "${var.ansible_vars_oracle_db["database_global_database_name"]}S1"
    database_sid                  = "${var.ansible_vars_oracle_db["database_sid"]}S1"
    database_characterset         = "${var.ansible_vars_oracle_db["database_characterset"]}"
    oracle_dbca_template_file     = "${var.ansible_vars_oracle_db["oracle_dbca_template_file"]}"
    s3_oracledb_backups_arn       = "${data.terraform_remote_state.s3-oracledb-backups.s3_oracledb_backups.arn}"
    database_type                 = "standby" # required for the DB module. This file is where the property is set.

    ## the following are retrieved from SSM Parameter Store
    ## oradb_sys_password            = "/${environment_name}/${project}/delius-database/db/oradb_sys_password"
    ## oradb_system_password         = "/${environment_name}/${project}/delius-database/db/oradb_system_password"
    ## oradb_sysman_password         = "/${environment_name}/${project}/delius-database/db/oradb_sysman_password"
    ## oradb_dbsnmp_password         = "/${environment_name}/${project}/delius-database/db/oradb_dbsnmp_password"
    ## oradb_asmsnmp_password        = "/${environment_name}/${project}/delius-database/db/oradb_asmsnmp_password"
  }
}

#legacy (used for info only)
output "ami_delius_db_2" {
  value = "${module.delius_db_2.ami_id}"
}

output "public_fqdn_delius_db_2" {
  value = "${module.delius_db_2.public_fqdn}"
}

output "internal_fqdn_delius_db_2" {
  value = "${module.delius_db_2.internal_fqdn}"
}

output "private_ip_delius_db_2" {
  value = "${module.delius_db_2.private_ip}"
}

output "db_disks_delius_db_2" {
  value = "${module.delius_db_2.db_size_parameters}"
}

# map (tidier)
output "delius_db_2" {
  value = {
    ami_id        = "${module.delius_db_2.ami_id}",
    public_fqdn   = "${module.delius_db_2.public_fqdn}",
    internal_fqdn = "${module.delius_db_2.internal_fqdn}",
    private_ip    = "${module.delius_db_2.private_ip}",
    db_disks      = "${module.delius_db_2.db_size_parameters}",
    delius_db_2   = "ssh ${module.delius_db_2.public_fqdn}",
  }
}
