resource "aws_internet_gateway" "main" {
  vpc_id            = "${aws_vpc.vpc.id}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}"))}"
}

