resource "aws_vpc_peering_connection" "bastion_peering" {
  peer_owner_id = "${var.bastion_account_id}"
  peer_vpc_id   = "${var.bastion_vpc_id}"
  vpc_id        = "${aws_vpc.vpc.id}"
}

resource "aws_route" "bastion_route_db_a" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.db_a.id}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
}

resource "aws_route" "bastion_route_db_b" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.db_b.id}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
}

resource "aws_route" "bastion_route_private_a" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.private_a.id}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
}

resource "aws_route" "bastion_route_private_b" {
  count                     = "${length(var.bastion_cidrs)}"
  route_table_id            = "${aws_route_table.private_b.id}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  destination_cidr_block    = "${var.bastion_cidrs[count.index]}"
}
