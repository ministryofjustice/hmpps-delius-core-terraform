################################################################################
## Load Balancer
################################################################################
resource "aws_security_group" "community_api_lb" {
  name        = "${var.environment_name}-community-api-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Community API load balancer"
  tags        = merge(var.tags, { Name = "${var.environment_name}-community-api-lb" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_community_api_lb_id" {
  value = aws_security_group.community_api_lb.id
}

resource "aws_security_group_rule" "community_api_lb_from_internal_users" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.community_api_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = concat(local.bastion_public_ip, var.internal_moj_access_cidr_blocks, local.natgateway_public_ips_cidr_blocks)
  description       = "In from internal IP ranges on port ${each.value}"
}

resource "aws_security_group_rule" "community_api_lb_from_allowed_ips" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.community_api_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = concat(var.default_community_api_ingress, var.community_api_ingress)
  description       = "In from external IP ranges on port ${each.value}"
}

resource "aws_security_group_rule" "community_api_lb_to_instances" {
  security_group_id        = aws_security_group.community_api_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.community_api_instances.id
  description              = "Out to Community API instances"
}

################################################################################
## Public / unrestricted Load balancer (for exposing documentation)
################################################################################
resource "aws_security_group" "community_api_public_lb" {
  name        = "${var.environment_name}-community-api-public-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Community API public / unrestricted access"
  tags        = merge(var.tags, { Name = "${var.environment_name}-community-api-public-lb" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_community_api_public_lb_id" {
  value = aws_security_group.community_api_public_lb.id
}

resource "aws_security_group_rule" "community_api_public_lb_from_everywhere" {
  security_group_id = aws_security_group.community_api_public_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "In from everywhere"
}

resource "aws_security_group_rule" "community_api_public_lb_to_instances" {
  security_group_id        = aws_security_group.community_api_public_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.community_api_instances.id
  description              = "Out to Community API instances"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "community_api_instances" {
  name        = "${var.environment_name}-community-api-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Community API instances"
  tags        = merge(var.tags, { Name = "${var.environment_name}-community-api-instances" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_community_api_instances_id" {
  value = aws_security_group.community_api_instances.id
}

resource "aws_security_group_rule" "community_api_instances_in_from_lb" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.community_api_lb.id
  security_group_id        = aws_security_group.community_api_instances.id
  description              = "In from Community API load balancer"
}

resource "aws_security_group_rule" "community_api_instances_in_from_public_lb" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.community_api_public_lb.id
  security_group_id        = aws_security_group.community_api_instances.id
  description              = "In from public Community API load balancer"
}

resource "aws_security_group_rule" "community_api_instances_in_from_new_tech" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.new_tech_instances.id
  security_group_id        = aws_security_group.community_api_instances.id
  description              = "In from New Tech web service instances"
}

resource "aws_security_group_rule" "community_api_instances_out_to_delius_db" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  security_group_id        = aws_security_group.community_api_instances.id
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Out to Delius database"
}

resource "aws_security_group_rule" "community_api_instances_out_to_delius_ldap" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  security_group_id        = aws_security_group.community_api_instances.id
  source_security_group_id = aws_security_group.apacheds_ldap_private_elb.id
  description              = "Out to Delius LDAP"
}

resource "aws_security_group_rule" "community_api_instances_out_to_delius_ldap_mp" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 389
  to_port                  = 389
  security_group_id        = aws_security_group.community_api_instances.id
  cidr_blocks              = [var.mp_corresponding_vpc_cidr]
  description              = "LDAP out to MP"
}

resource "aws_security_group_rule" "community_api_instances_out_to_delius_interface" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 7001
  to_port                  = 7001
  security_group_id        = aws_security_group.community_api_instances.id
  source_security_group_id = aws_security_group.weblogic_interface_instances.id
  description              = "Out to Delius WebLogic interface domain (Case Notes API)"
}

resource "aws_security_group_rule" "community_api_instances_out_to_delius_api" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  security_group_id        = aws_security_group.community_api_instances.id
  source_security_group_id = aws_security_group.delius_api_instances.id
  description              = "Out to Delius API"
}
