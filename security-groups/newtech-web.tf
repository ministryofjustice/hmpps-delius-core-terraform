# Create the SG here to allow ALB rules to be specified
resource "aws_security_group" "newtech_web" {
  name        = "${var.environment_name}-delius-newtechweb-sg"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "New Tech Web Frontend Security Group"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-newtechweb-sg", "Type", "Private"))}"

  lifecycle {
    create_before_destroy = true
  }
}

# General egress rules
# More specific rules are managed via the newtech web ecs task terraform component, to avoid deployment circular dependencies
resource "aws_security_group_rule" "newtechweb_https_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.newtech_web.id}"
}

resource "aws_security_group_rule" "newtechweb_dnssec_out" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.newtech_web.id}"
}

resource "aws_security_group_rule" "newtechweb_dns_out" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.newtech_web.id}"
}

resource "aws_security_group_rule" "newtechweb_alb_in" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_ndelius_lb.id}"
  security_group_id = "${aws_security_group.newtech_web.id}"
}

resource "aws_security_group_rule" "newtechweb_spg_alb_in" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_spg_lb.id}"
  security_group_id = "${aws_security_group.newtech_web.id}"
}

resource "aws_security_group_rule" "newtechweb_interface_alb_in" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.weblogic_interface_lb.id}"
  security_group_id = "${aws_security_group.newtech_web.id}"
}

output "sg_newtech_web_id" {
  value = "${aws_security_group.newtech_web.id}"
}
