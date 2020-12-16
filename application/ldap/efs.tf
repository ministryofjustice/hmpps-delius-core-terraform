resource "aws_efs_file_system" "efs" {
  creation_token                  = "${var.environment_name}-ldap-efs"
  encrypted                       = true
  throughput_mode                 = lookup(local.ldap_config, "efs_throughput_mode", null)
  provisioned_throughput_in_mibps = lookup(local.ldap_config, "efs_provisioned_throughput", null)
  tags                            = merge(var.tags, { "Name" = "${var.environment_name}-ldap-efs" })
}

resource "aws_efs_mount_target" "efs_az1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_ldap_efs_id]
}

resource "aws_efs_mount_target" "efs_az2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_ldap_efs_id]
}

resource "aws_efs_mount_target" "efs_az3" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_ldap_efs_id]
}

