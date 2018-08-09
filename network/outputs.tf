output "vpc_id" {
  value = "${module.network.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.network.vpc_cidr_block}"
}

output "bastion_peering_id" {
  value = "${module.network.bastion_peering_id}"
}

output "bastion_peering_value" {
  value = "${module.network.bastion_peering_id},${module.network.vpc_cidr_block}"
}
