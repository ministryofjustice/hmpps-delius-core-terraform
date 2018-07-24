resource "aws_route_table" "public_a" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[0]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[1]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[2]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}_public_a"))}"
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public_a.id}"
}

resource "aws_route_table" "public_b" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[0]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[1]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[2]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }

  tags = "${merge(var.tags, map("Name", "${var.environment_name}_public_b"))}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public_b.id}"
}

resource "aws_route_table" "private_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_private_a"))}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  route {
    cidr_block = "${var.bastion_cidrs[0]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[1]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[2]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }

}

resource "aws_route_table_association" "private_a" {
  subnet_id      = "${aws_subnet.private_a.id}"
  route_table_id = "${aws_route_table.private_a.id}"
}

resource "aws_route_table" "private_b" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_private_b"))}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  route {
    cidr_block = "${var.bastion_cidrs[0]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[1]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[2]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }

}

resource "aws_route_table_association" "private_b" {
  subnet_id      = "${aws_subnet.private_b.id}"
  route_table_id = "${aws_route_table.private_b.id}"
}

resource "aws_route_table" "db_a" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_db_a"))}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  route {
    cidr_block = "${var.bastion_cidrs[0]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[1]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[2]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }

}

resource "aws_route_table_association" "db_a" {
  subnet_id      = "${aws_subnet.db_a.id}"
  route_table_id = "${aws_route_table.db_a.id}"
}

resource "aws_route_table" "db_b" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = "${merge(var.tags, map("Name", "${var.environment_name}_db_b"))}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  route {
    cidr_block = "${var.bastion_cidrs[0]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[1]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }
  route {
    cidr_block = "${var.bastion_cidrs[2]}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.bastion_peering.id}"
  }

}

resource "aws_route_table_association" "db_b" {
  subnet_id      = "${aws_subnet.db_b.id}"
  route_table_id = "${aws_route_table.db_b.id}"
}
