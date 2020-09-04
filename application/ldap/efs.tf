resource "aws_efs_file_system" "efs" {
  creation_token = "${var.environment_name}-ldap-efs"
  encrypted      = true
  tags           = "${merge(var.tags, map("Name", "${var.environment_name}-ldap-efs"))}"
}

resource "aws_efs_mount_target" "efs_az1" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}"
  security_groups = ["${data.terraform_remote_state.delius_core_security_groups.sg_ldap_efs_id}"]
}

resource "aws_efs_mount_target" "efs_az2" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${data.terraform_remote_state.vpc.vpc_private-subnet-az2}"
  security_groups = ["${data.terraform_remote_state.delius_core_security_groups.sg_ldap_efs_id}"]
}

resource "aws_efs_mount_target" "efs_az3" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${data.terraform_remote_state.vpc.vpc_private-subnet-az3}"
  security_groups = ["${data.terraform_remote_state.delius_core_security_groups.sg_ldap_efs_id}"]
}
