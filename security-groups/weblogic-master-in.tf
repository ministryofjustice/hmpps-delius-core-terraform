# weblogic-master-in.tf

resource "aws_security_group" "wls_mstr_in" {
  name        = "${local.environment_name}-wls-mstr-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "Weblogic master in"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_wls_mstr_in", "Type", "WLS"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_security_group_rule" "wls_mstr_in" {
#   security_group_id = "${aws_security_group.wls_mstr_in.id}"
#   type              = "ingress"
#   from_port         = 7001
#   to_port           = 7002
#   protocol          = "tcp"
#   source_security_group_id = "${aws_security_group.wls_mstr_out.id}"
# }

resource "aws_security_group_rule" "wls_mstr_in_whitelist" {
  security_group_id = "${aws_security_group.wls_mstr_in.id}"
  type              = "ingress"
  from_port         = 7001
  to_port           = 7002
  protocol          = "tcp"
  cidr_blocks       = ["${var.bastion_cidrs}"]
}
