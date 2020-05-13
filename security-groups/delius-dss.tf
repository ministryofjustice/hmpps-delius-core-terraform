# Create a dedicated security group with no ingress for the batch compute environment
# Requires egress for pulling images from container registry and connection to p-nomis and delius endpoints
resource "aws_security_group" "delius_dss_out" {
  name        = "${var.environment_name}-delius-dss-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius database in"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-dss-out", "Type", "Private"))}"
}


resource "aws_security_group_rule" "delius_dss_out" {
  security_group_id = "${aws_security_group.delius_dss_out.id}"
  cidr_blocks = ["0.0.0.0/0"]
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Outbound HTTPS"
}

resource "aws_security_group_rule" "dss_dnssec_out" {
  type            = "egress"
  from_port       = 53
  to_port         = 53
  protocol        = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.delius_dss_out.id}"
}

resource "aws_security_group_rule" "dss_dns_out" {
  type            = "egress"
  from_port       = 53
  to_port         = 53
  protocol        = "udp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.delius_dss_out.id}"
}

output "sg_delius_dss_out_id" {
  value = "${aws_security_group.delius_dss_out.id}"
}