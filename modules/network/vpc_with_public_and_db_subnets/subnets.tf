resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 0)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_a", "Type", "public"))}"
}

resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_public_b", "Type", "public"))}"
}

resource "aws_subnet" "private_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 2)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_a", "Type", "private"))}"
}

resource "aws_subnet" "private_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 3)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_private_b", "Type", "private"))}"
}

resource "aws_subnet" "db_a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 4)}"
  availability_zone = "${var.az_a}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_a", "Type", "DB"))}"
}

resource "aws_subnet" "db_b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 3, 5)}"
  availability_zone = "${var.az_b}"
  tags              = "${merge(var.tags, map("Name", "${var.environment_name}_db_b", "Type", "DB"))}"
}
