# common-out.tf

################################################################################
## common_out
################################################################################
resource "aws_security_group" "common_out" {
  name        = "${var.environment_name}-common-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Common egress rules"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-common-out", "Type", "COMMON"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_common_out_id" {
  value = "${aws_security_group.common_out.id}"
}

# This is a temp solution to enable quick access to yum repos from dev env
# during discovery.
resource "aws_security_group_rule" "common_out_80" {
  count             = "${var.egress_80}"
  security_group_id = "${aws_security_group.common_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "tmp yum repos"
}

# This is a temp solution to enable quick access to S3 bucket from dev env
# during discovery.
resource "aws_security_group_rule" "common_out_443" {
  count             = "${var.egress_443}"
  security_group_id = "${aws_security_group.common_out.id}"
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "tmp s3"
}
