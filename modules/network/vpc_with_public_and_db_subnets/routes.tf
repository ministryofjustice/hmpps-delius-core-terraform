resource "aws_route_table" "public_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_public_a"))}"
}

resource "aws_route_table_association" "public_a" {
  route_table_id = "${aws_route_table.public_a.id}"
  subnet_id      = "${aws_subnet.public_a.id}"
}

resource "aws_route" "public_a_internet" {
  route_table_id         = "${aws_route_table.public_a.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "public_a_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.public_a.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
}

resource "aws_route_table" "public_b" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_public_b"))}"
}

resource "aws_route_table_association" "public_b" {
  route_table_id = "${aws_route_table.public_b.id}"
  subnet_id      = "${aws_subnet.public_b.id}"
}

resource "aws_route" "public_b_internet" {
  route_table_id         = "${aws_route_table.public_b.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "public_b_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.public_b.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
}

resource "aws_route_table" "private_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_private_a"))}"
}

resource "aws_route_table_association" "private_a" {
  route_table_id = "${aws_route_table.private_a.id}"
  subnet_id      = "${aws_subnet.private_a.id}"
}

resource "aws_route" "private_a_internet" {
  route_table_id         = "${aws_route_table.private_a.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "private_a_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.private_a.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
}

resource "aws_route_table" "private_b" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_private_b"))}"
}

resource "aws_route_table_association" "private_b" {
  route_table_id = "${aws_route_table.private_b.id}"
  subnet_id      = "${aws_subnet.private_b.id}"
}

resource "aws_route" "private_b_internet" {
  route_table_id         = "${aws_route_table.private_b.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "private_b_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.private_b.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
}

resource "aws_route_table" "db_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_db_a"))}"
}

resource "aws_route_table_association" "db_a" {
  route_table_id = "${aws_route_table.db_a.id}"
  subnet_id      = "${aws_subnet.db_a.id}"
}

resource "aws_route" "db_a_internet" {
  route_table_id         = "${aws_route_table.db_a.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "db_a_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.db_a.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
}

resource "aws_route_table" "db_b" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_db_b"))}"
}

resource "aws_route_table_association" "db_b" {
  route_table_id = "${aws_route_table.db_b.id}"
  subnet_id      = "${aws_subnet.db_b.id}"
}

resource "aws_route" "db_b_internet" {
  route_table_id         = "${aws_route_table.db_b.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route" "db_b_bastion" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.db_b.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
}
