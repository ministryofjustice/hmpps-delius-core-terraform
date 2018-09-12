# #Weblogic tiers
#
# module "oid" {
#   source              = "../modules/weblogic"
#   tier_name           = "oid"
#   admin_port          = "${var.weblogic_domain_ports["oid_admin"]}"
#   admin_instance_type = "${var.instance_type_weblogic}"
#
#   admin_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_oid_admin.id}",
#   ]
#
#   managed_port          = "${var.weblogic_domain_ports["oid_ldap"]}"
#   managed_instance_type = "${var.instance_type_weblogic}"
#
#   managed_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_oid_managed.id}",
#   ]
#
#   private_subnet    = "${element(data.aws_subnet_ids.private.ids, 0)}"
#   public_subnets    = "${data.aws_subnet_ids.public.ids}"
#   tags              = "${var.tags}"
#   environment_name  = "${local.environment_name}"
#   dns_zone_id       = "${data.aws_route53_zone.zone.id}"
#   managed_elb_sg_id = "${data.aws_security_group.weblogic_oid_managed_elb.id}"
#   admin_elb_sg_id   = "${data.aws_security_group.weblogic_oid_admin_elb.id}"
# }
#
# module "ndelius" {
#   source              = "../modules/weblogic"
#   tier_name           = "ndelius"
#   admin_port          = "${var.weblogic_domain_ports["ndelius_managed"]}"
#   admin_instance_type = "${var.instance_type_weblogic}"
#
#   admin_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_ndelius_admin.id}",
#   ]
#
#   managed_port          = "${var.weblogic_domain_ports["ndelius_managed"]}"
#   managed_instance_type = "${var.instance_type_weblogic}"
#
#   managed_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_ndelius_managed.id}",
#   ]
#
#   private_subnet    = "${element(data.aws_subnet_ids.private.ids, 0)}"
#   public_subnets    = "${data.aws_subnet_ids.public.ids}"
#   tags              = "${var.tags}"
#   environment_name  = "${local.environment_name}"
#   dns_zone_id       = "${data.aws_route53_zone.zone.id}"
#   managed_elb_sg_id = "${data.aws_security_group.weblogic_ndelius_managed_elb.id}"
#   admin_elb_sg_id   = "${data.aws_security_group.weblogic_ndelius_admin_elb.id}"
# }
#
# module "spg" {
#   source              = "../modules/weblogic"
#   tier_name           = "spg"
#   admin_port          = "${var.weblogic_domain_ports["spg_admin"]}"
#   admin_instance_type = "${var.instance_type_weblogic}"
#
#   admin_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_spg_admin.id}",
#   ]
#
#   managed_port          = "${var.weblogic_domain_ports["spg_managed"]}"
#   managed_instance_type = "${var.instance_type_weblogic}"
#
#   managed_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_spg_managed.id}",
#   ]
#
#   private_subnet    = "${element(data.aws_subnet_ids.private.ids, 0)}"
#   public_subnets    = "${data.aws_subnet_ids.public.ids}"
#   tags              = "${var.tags}"
#   environment_name  = "${local.environment_name}"
#   dns_zone_id       = "${data.aws_route53_zone.zone.id}"
#   managed_elb_sg_id = "${data.aws_security_group.weblogic_spg_managed_elb.id}"
#   admin_elb_sg_id   = "${data.aws_security_group.weblogic_spg_admin_elb.id}"
# }
#
# module "interface" {
#   source              = "../modules/weblogic"
#   tier_name           = "interface"
#   admin_port          = "${var.weblogic_domain_ports["interface_admin"]}"
#   admin_instance_type = "${var.instance_type_weblogic}"
#
#   admin_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_interface_admin.id}",
#   ]
#
#   managed_port          = "${var.weblogic_domain_ports["interface_managed"]}"
#   managed_instance_type = "${var.instance_type_weblogic}"
#
#   managed_security_groups = [
#     "${data.aws_security_group.ssh_bastion_in.id}",
#     "${data.aws_security_group.weblogic_interface_managed.id}",
#   ]
#
#   private_subnet    = "${element(data.aws_subnet_ids.private.ids, 0)}"
#   public_subnets    = "${data.aws_subnet_ids.public.ids}"
#   tags              = "${var.tags}"
#   environment_name  = "${local.environment_name}"
#   dns_zone_id       = "${data.aws_route53_zone.zone.id}"
#   managed_elb_sg_id = "${data.aws_security_group.weblogic_interface_managed_elb.id}"
#   admin_elb_sg_id   = "${data.aws_security_group.weblogic_interface_admin_elb.id}"
# }
