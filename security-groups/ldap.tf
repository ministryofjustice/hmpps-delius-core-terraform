# ldap.tf

################################################################################
## Load Balancer
################################################################################
resource "aws_security_group" "apacheds_ldap_private_elb" {
  name        = "${var.environment_name}-apacheds-ldap-private-elb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Apache DS LDAP Server Private ELB"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-apacheds-ldap-private-elb"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_apacheds_ldap_private_elb_id" {
  value = aws_security_group.apacheds_ldap_private_elb.id
}

resource "aws_security_group_rule" "ldap_lb_instances_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.apacheds_ldap.id
  description              = "LDAP instances in"
}

resource "aws_security_group_rule" "ldap_lb_instances_egress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.apacheds_ldap.id
  description              = "LDAP instances out"
}

resource "aws_security_group_rule" "ldap_lb_instances_egress_80" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.apacheds_ldap.id
  description              = "LDAP instances out"
}

resource "aws_security_group_rule" "ldap_lb_weblogic_interface_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.weblogic_interface_instances.id
  description              = "WebLogic (interface) in"
}

resource "aws_security_group_rule" "ldap_lb_weblogic_ndelius_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.weblogic_ndelius_instances.id
  description              = "WebLogic (ndelius) in"
}

resource "aws_security_group_rule" "management_ldap_out" {
  security_group_id        = data.terraform_remote_state.network_security_groups.outputs.sg_management_server_id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.apacheds_ldap_private_elb.id
  description              = "Delius LDAP out"
}

resource "aws_security_group_rule" "ldap_lb_management_server_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = data.terraform_remote_state.network_security_groups.outputs.sg_management_server_id
  description              = "Management server in"
}

resource "aws_security_group_rule" "ldap_lb_pwm_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.pwm_instances.id
  description              = "Password manager in"
}

#Allow UMT in
resource "aws_security_group_rule" "ldap_lb_umt_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.umt_instances.id
  description              = "User Management Tool in"
}

resource "aws_security_group_rule" "ldap_lb_newtech_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap_private_elb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.community_api_instances.id
  description              = "Community API In"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "apacheds_ldap" {
  name        = "${var.environment_name}-apacheds-ldap"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "ApacheDS LDAP server"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-apacheds-ldap"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_apacheds_ldap_id" {
  value = aws_security_group.apacheds_ldap.id
}

resource "aws_security_group_rule" "ldap_instances_lb_ingress" {
  security_group_id        = aws_security_group.apacheds_ldap.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.apacheds_ldap_private_elb.id
  description              = "Load Balancer in"
}

resource "aws_security_group_rule" "ldap_instances_lb_ingress_80" {
  security_group_id        = aws_security_group.apacheds_ldap.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.apacheds_ldap_private_elb.id
  description              = "Load Balancer in"
}

#Allow the instances to see each other
resource "aws_security_group_rule" "ldap_instances_self_ingress" {
  security_group_id = aws_security_group.apacheds_ldap.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = var.ldap_ports["ldap"]
  to_port           = var.ldap_ports["ldap"]
  self              = true
  description       = "LDAP instances in"
}

resource "aws_security_group_rule" "ldap_instances_self_egress" {
  security_group_id = aws_security_group.apacheds_ldap.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = var.ldap_ports["ldap"]
  to_port           = var.ldap_ports["ldap"]
  self              = true
  description       = "LDAP instances out"
}

resource "aws_security_group_rule" "ldap_instances_self_ingress_80" {
  security_group_id = aws_security_group.apacheds_ldap.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  self              = true
  description       = "LDAP instances in"
}

resource "aws_security_group_rule" "ldap_instances_self_egress_80" {
  security_group_id = aws_security_group.apacheds_ldap.id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  self              = true
  description       = "LDAP instances out"
}

resource "aws_security_group_rule" "ldap_instances_efs_egress" {
  security_group_id        = aws_security_group.apacheds_ldap.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  source_security_group_id = aws_security_group.ldap_efs.id
  description              = "Out to EFS"
}

################################################################################
## EFS File System
################################################################################
resource "aws_security_group" "ldap_efs" {
  name        = "${var.environment_name}-ldap-efs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "LDAP EFS File System"
  tags = merge(
    var.tags,
    {
      "Name" = "${var.environment_name}-ldap-efs"
      "Type" = "Private"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_ldap_efs_id" {
  value = aws_security_group.ldap_efs.id
}

resource "aws_security_group_rule" "ldap_efs_instances_ingress" {
  security_group_id        = aws_security_group.ldap_efs.id
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.apacheds_ldap.id
  description              = "In from LDAP instances"
}

