################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "weblogic_interface_lb" {
  name        = "${var.environment_name}-weblogic-interface-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic interface LB"
  tags = merge(var.tags, {
    "Name" = "${var.environment_name}-weblogic-interface-lb"
    "Type" = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_lb_id" {
  value = aws_security_group.weblogic_interface_lb.id
}

resource "aws_security_group_rule" "interface_lb_ingress_from_external_systems" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.weblogic_interface_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = var.interface_access_cidr_blocks
  description       = "External interfacing systems"
}

resource "aws_security_group_rule" "interface_lb_ingress_from_dss" {
  for_each                 = toset(["80", "443"])
  security_group_id        = aws_security_group.weblogic_interface_lb.id
  source_security_group_id = aws_security_group.delius_dss_out.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = each.value
  to_port                  = each.value
  description              = "DSS batch job"
}

resource "aws_security_group_rule" "interface_lb_ingress_from_internal_users" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.weblogic_interface_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = concat(local.bastion_public_ip, var.internal_moj_access_cidr_blocks, local.natgateway_public_ips_cidr_blocks)
  description       = "Internal user access"
}

resource "aws_security_group_rule" "interface_lb_egress_to_instances" {
  security_group_id        = aws_security_group.weblogic_interface_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_interface_instances.id
  description              = "Out to WebLogic instances"
}


################################################################################
## Instances
################################################################################
resource "aws_security_group" "weblogic_interface_instances" {
  name        = "${var.environment_name}-weblogic-interface-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic interface instances"
  tags = merge(var.tags, {
    "Name" = "${var.environment_name}-weblogic-interface-instances"
    "Type" = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_interface_instances_id" {
  value = aws_security_group.weblogic_interface_instances.id
}

resource "aws_security_group_rule" "interface_instances_lb_ingress" {
  security_group_id        = aws_security_group.weblogic_interface_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_interface_lb.id
  description              = "Load balancer in"
}

# Note: As Community-API and WebLogic are both deployed to the same ECS cluster, traffic is routed directly to the
# instances using service discovery. The Load Balancer is only used for access from outside the cluster.
resource "aws_security_group_rule" "interface_external_elb_ingress_from_community_api" {
  security_group_id        = aws_security_group.weblogic_interface_instances.id
  source_security_group_id = aws_security_group.community_api_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 7001
  to_port                  = 7001
  description              = "Community API in to Case Notes API"
}

resource "aws_security_group_rule" "interface_instances_egress_to_database" {
  security_group_id        = aws_security_group.weblogic_interface_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "interface_instances_egress_to_ldap" {
  security_group_id        = aws_security_group.weblogic_interface_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.apacheds_ldap_private_elb.id
  description              = "LDAP ELB out"
}

resource "aws_security_group_rule" "interface_instances_egress_to_ldap_mp" {
  security_group_id        = aws_security_group.weblogic_interface_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 389
  to_port                  = 389
  cidr_blocks              = [var.mp_corresponding_vpc_cidr]
  description              = "LDAP out to MP"
}
