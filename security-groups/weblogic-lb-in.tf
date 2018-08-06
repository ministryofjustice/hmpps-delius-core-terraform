# weblogic-lb-in.tf

resource "aws_security_group" "weblogic_lb_in" {
  name        = "${local.environment_name}-weblogic-lb-in"
  vpc_id      = "${data.aws_vpc.vpc.id}"
  description = "ELB"
  tags        = "${merge(var.tags, map("Name", "${local.environment_name}_weblogic_lb_in", "Type", "LB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

## ingress rules
resource "aws_security_group_rule" "http_in_weblogic_lb_in" {
  security_group_id = "${aws_security_group.weblogic_lb_in.id}"
  type              = "ingress"
  from_port         = 9704
  to_port           = 9704
  protocol          = "tcp"
  cidr_blocks       = ["${var.bastion_cidrs}"]
}
