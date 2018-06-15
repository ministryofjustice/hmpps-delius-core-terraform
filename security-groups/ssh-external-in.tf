resource "aws_security_group" "ssh_external_in" {
  name        = "${local.environment_name}-ssh-external-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "SSH external in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_ssh_external_in", "Type", "SSH"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_external_in" {
  security_group_id = "${aws_security_group.ssh_external_in.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.whitelist_cidrs}"]
}
