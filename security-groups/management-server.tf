################################################################################
## management-server - no longer used, see hmpps-delius-network-terraform
################################################################################
resource "aws_security_group" "management_server" {
  name        = "${var.environment_name}-management"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Management instance SG"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-management", "Type", "Private"))}"
}

output "sg_management_id" {
  value = "${aws_security_group.management_server.id}"
}
