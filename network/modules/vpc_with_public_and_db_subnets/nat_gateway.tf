resource "aws_eip" "nat" {
  vpc   = true
  tags  = "${merge(var.tags, map("Name", "${var.environment_name}-nat-gw"))}"
}

resource "aws_nat_gateway" "gw" {
  allocation_id     = "${aws_eip.nat.id}"
  subnet_id         = "${aws_subnet.public_a.id}"
  depends_on        = ["aws_internet_gateway.main"]
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}"))}"
}
