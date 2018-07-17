output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "bastion_peering_id" {
  value = "${aws_vpc_peering_connection.bastion_peering.id}"
}