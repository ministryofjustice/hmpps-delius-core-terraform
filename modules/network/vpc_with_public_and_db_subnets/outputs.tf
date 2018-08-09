output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "bastion_peering_id" {
  value = "${aws_vpc_peering_connection.bastion_peering.id}"
}
