#Weblogic tiers

module "oid" {
  source              = "../modules/weblogic"
  tier_name           = "oid"
  admin_port          = "7001"
  admin_instance_type = "${var.instance_type_weblogic}"

  admin_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  managed_port          = "9704"
  managed_instance_type = "${var.instance_type_weblogic}"

  managed_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  private_subnet   = "${data.aws_subnet.private_a.id}"
  public_subnets   = "${data.aws_subnet_ids.public.ids}"
  tags             = "${var.tags}"
  environment_name = "${local.environment_name}"
  dns_zone_id      = "${data.aws_route53_zone.zone.id}"
  elb_sg_id        = "${data.aws_security_group.elb.id}"
}

module "ndelius" {
  source              = "../modules/weblogic"
  tier_name           = "ndelius"
  admin_port          = "7001"
  admin_instance_type = "${var.instance_type_weblogic}"

  admin_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  managed_port          = "9704"
  managed_instance_type = "${var.instance_type_weblogic}"

  managed_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  private_subnet   = "${data.aws_subnet.private_a.id}"
  public_subnets   = "${data.aws_subnet_ids.public.ids}"
  tags             = "${var.tags}"
  environment_name = "${local.environment_name}"
  dns_zone_id      = "${data.aws_route53_zone.zone.id}"
  elb_sg_id        = "${data.aws_security_group.elb.id}"
}

/*
module "spg" {
  source              = "../modules/weblogic"
  tier_name           = "spg"
  admin_port          = "7001"
  admin_instance_type = "${var.instance_type_weblogic}"

  admin_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  managed_port          = "9704"
  managed_instance_type = "${var.instance_type_weblogic}"

  managed_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  private_subnet   = "${data.aws_subnet.private_a.id}"
  public_subnets   = "${data.aws_subnet_ids.public.ids}"
  tags             = "${var.tags}"
  environment_name = "${local.environment_name}"
  dns_zone_id      = "${data.aws_route53_zone.zone.id}"
  elb_sg_id        = "${data.aws_security_group.elb.id}"
}
*/

/*
module "interface" {
  source              = "../modules/weblogic"
  tier_name           = "interface"
  admin_port          = "7001"
  admin_instance_type = "${var.instance_type_weblogic}"

  admin_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  managed_port          = "9704"
  managed_instance_type = "${var.instance_type_weblogic}"

  managed_security_groups = [
    "${data.aws_security_group.weblogic_in.id}",
    "${data.aws_security_group.egress_all.id}",
    "${data.aws_security_group.ssh_in.id}",
    "${data.aws_security_group.db_out.id}",
  ]

  private_subnet   = "${data.aws_subnet.private_a.id}"
  public_subnets   = "${data.aws_subnet_ids.public.ids}"
  tags             = "${var.tags}"
  environment_name = "${local.environment_name}"
  dns_zone_id      = "${data.aws_route53_zone.zone.id}"
  elb_sg_id        = "${data.aws_security_group.elb.id}"
}*/
