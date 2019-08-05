# Create a dedicated security group with no ingress for the batch compute environment
# Requires egress for pulling images from container registry and connection to p-nomis and delius endpoints
resource "aws_security_group" "newtech_offenderapi_out" {
  name        = "${var.environment_name}-delius-offapi-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "New Tech Offender API Outbound Security Group"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-offapi-out", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group_rule" "newtech_offenderapi_db" {
  security_group_id = "${aws_security_group.newtech_offenderapi_out.id}"
  source_security_group_id = "${aws_security_group.delius_db_in.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "1521"
  to_port           = "1521"
  description       = "New Tech Offender API Egress to Delius Oracle DB"
}

resource "aws_security_group_rule" "newtech_offenderapi_ldap" {
  security_group_id = "${aws_security_group.newtech_offenderapi_out.id}"
  source_security_group_id = "${aws_security_group.apacheds_ldap_private_elb.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "${var.ldap_ports["ldap"]}"
  to_port           = "${var.ldap_ports["ldap"]}"
  description       = "New Tech Offender API Egress to Delius LDAP"
}

output "sg_newtech_offenderapi_out_id" {
  value = "${aws_security_group.newtech_offenderapi_out.id}"
}