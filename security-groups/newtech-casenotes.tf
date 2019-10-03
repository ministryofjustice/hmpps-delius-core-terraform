# Requires egress for pulling images from container registry and connection to p-nomis and delius endpoints
resource "aws_security_group" "newtech_casenotes_out" {
  name        = "${var.environment_name}-delius-casenotes-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "New Tech Casenotes Outbound Security Group"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-casenotes-out", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group_rule" "newtech_casenotes_api" {
  security_group_id = "${aws_security_group.newtech_casenotes_out.id}"
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  description       = "New Tech Casenotes Poll/Push egress to interface LB"
}

output "sg_newtech_casenotes_out_id" {
  value = "${aws_security_group.newtech_casenotes_out.id}"
}