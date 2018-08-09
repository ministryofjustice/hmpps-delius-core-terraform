output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.network.vpc_cidr_block}"
}

output "bastion_peering_id" {
  value = "${module.network.bastion_peering_id}"
}
