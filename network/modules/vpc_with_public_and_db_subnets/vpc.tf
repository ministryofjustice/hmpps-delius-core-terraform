resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  tags       = "${merge(var.tags, map("Name", "${var.environment_name}"))}"
}

