resource "aws_vpc_peering_connection" "bastion_peering" {
  peer_owner_id = "${var.bastion_account_id}"
  peer_vpc_id   = "${var.bastion_vpc_id}"
  vpc_id        = "${aws_vpc.vpc.id}"
  tags          = "${merge(var.tags, map("Name", "${var.environment_name}-to-bastion-vpc"))}"
}
