resource "aws_security_group" "ssh_bastion_in" {
  name        = "${local.environment_name}-ssh-bastion-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "SSH bastion in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_ssh_bastion_in", "Type", "SSH"))}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_bastion_in" {
  security_group_id = "${aws_security_group.ssh_bastion_in.id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = "${var.bastion_cidrs}"
}
