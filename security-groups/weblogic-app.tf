locals {
  counterpart_mp_env_cidr = {
    delius-mis-dev  = "10.26.24.0/21" #mp hmpps-development
    delius-test     = "10.26.8.0/21"  #mp hmpps-test
    delius-training = "10.26.8.0/21"  #mp hmpps-test
    delius-stage    = "10.27.0.0/21"  #mp hmpps-preproduction
    delius-pre-prod = "10.27.0.0/21"  #mp hmpps-preproduction
    delius-prod     = "10.27.8.0/21"  #mp hmpps-production
  }
}


################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "weblogic_ndelius_lb" {
  name        = "${var.environment_name}-weblogic-ndelius-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic ndelius LB"
  tags = merge(var.tags, {
    "Name" = "${var.environment_name}-weblogic-ndelius-lb"
    "Type" = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_lb_id" {
  value = aws_security_group.weblogic_ndelius_lb.id
}

# Allow Probation users and MOJ internal users into the external LB
resource "aws_security_group_rule" "ndelius_lb_ingress_from_users" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.weblogic_ndelius_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = distinct(concat(local.user_access_cidr_blocks, local.bastion_public_ip, var.internal_moj_access_cidr_blocks, local.natgateway_public_ips_cidr_blocks))
  description       = "User access"
}

# Allow Uservision users into the external LB
resource "aws_security_group_rule" "ndelius_lb_ingress_from_uservision_users" {
  for_each          = var.environment_name == "delius-test" ? toset(["80", "443"]) : []
  security_group_id = aws_security_group.weblogic_ndelius_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = ["5.181.59.114/32"] # Uservision IP see https://mojdt.slack.com/archives/C6C1KGRME/p1702559900527159?thread_ts=1702031639.455009&cid=C6C1KGRME
  description       = "User access only for test - Uservision"
}

resource "aws_security_group_rule" "ndelius_lb_egress_to_instances" {
  security_group_id        = aws_security_group.weblogic_ndelius_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_ndelius_instances.id
  description              = "Out to WebLogic instances"
}

resource "aws_security_group_rule" "ndelius_lb_egress_to_services" {
  for_each = {
    "User Management" = [aws_security_group.umt_instances.id, 8080]
    "New Tech Web"    = [aws_security_group.new_tech_instances.id, 9000]
    "GDPR API"        = [aws_security_group.gdpr_api.id, 8080]
    "GDPR UI"         = [aws_security_group.gdpr_ui.id, 80]
    "Merge API"       = [aws_security_group.merge_api.id, 8080]
    "Merge UI"        = [aws_security_group.merge_ui.id, 80]
  }
  security_group_id        = aws_security_group.weblogic_ndelius_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = each.value[1]
  to_port                  = each.value[1]
  source_security_group_id = each.value[0]
  description              = "Out to ${each.key}"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "weblogic_ndelius_instances" {
  name        = "${var.environment_name}-weblogic-ndelius-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic ndelius instances"
  tags = merge(var.tags, {
    "Name" = "${var.environment_name}-weblogic-ndelius-instances"
    "Type" = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_ndelius_instances_id" {
  value = aws_security_group.weblogic_ndelius_instances.id
}

resource "aws_security_group_rule" "ndelius_instances_lb_ingress" {
  security_group_id        = aws_security_group.weblogic_ndelius_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_ndelius_lb.id
  description              = "Load balancer in"
}

resource "aws_security_group_rule" "ndelius_instances_egress_to_database" {
  security_group_id        = aws_security_group.weblogic_ndelius_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "ndelius_instances_egress_to_ldap" {
  security_group_id        = aws_security_group.weblogic_ndelius_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = var.ldap_ports["ldap"]
  to_port                  = var.ldap_ports["ldap"]
  source_security_group_id = aws_security_group.apacheds_ldap_private_elb.id
  description              = "LDAP ELB out"
}

resource "aws_security_group_rule" "ndelius_instances_egress_to_ldap_mp" {
  security_group_id        = aws_security_group.weblogic_ndelius_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 389
  to_port                  = 389
  cidr_blocks              = [var.mp_corresponding_vpc_cidr]
  description              = "LDAP out to MP"
}

resource "aws_security_group_rule" "ndelius_instances_egress_to_merge_api" {
  security_group_id        = aws_security_group.weblogic_ndelius_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.merge_api.id
  description              = "Merge API out"
}

resource "aws_security_group_rule" "ndelius_instances_egress_to_mp_vpc" {
  security_group_id        = aws_security_group.weblogic_ndelius_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1522
  cidr_blocks              = [local.counterpart_mp_env_cidr[var.environment_name]]
  description              = "Oracle outbound to MP"
}
