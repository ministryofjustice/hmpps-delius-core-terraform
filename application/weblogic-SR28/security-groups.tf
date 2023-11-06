################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "weblogic_SR28_lb" {
  name        = "${var.environment_name}-weblogic-SR28-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic SR28 LB"
  tags = merge(var.tags, {
    "Name" = "${var.environment_name}-weblogic-SR28-lb"
    "Type" = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_SR28_lb_id" {
  value = aws_security_group.weblogic_SR28_lb.id
}

# Allow Probation users and MOJ internal users into the external LB
resource "aws_security_group_rule" "SR28_lb_ingress_from_users" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.weblogic_SR28_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = distinct(concat(var.internal_moj_access_cidr_blocks, local.natgateway_public_ips_cidr_blocks))
  description       = "User access"
}

resource "aws_security_group_rule" "SR28_lb_egress_to_instances" {
  security_group_id        = aws_security_group.weblogic_SR28_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_SR28_instances.id
  description              = "Out to WebLogic instances"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "weblogic_SR28_instances" {
  name        = "${var.environment_name}-weblogic-SR28-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Weblogic SR28 instances"
  tags = merge(var.tags, {
    "Name" = "${var.environment_name}-weblogic-SR28-instances"
    "Type" = "Private"
  })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_weblogic_SR28_instances_id" {
  value = aws_security_group.weblogic_SR28_instances.id
}

resource "aws_security_group_rule" "SR28_instances_lb_ingress" {
  security_group_id        = aws_security_group.weblogic_SR28_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_SR28_lb.id
  description              = "Load balancer in"
}

resource "aws_security_group_rule" "SR28_instances_egress_to_database" {
  security_group_id        = aws_security_group.weblogic_SR28_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_db_in_id
  description              = "Delius DB out"
}

resource "aws_security_group_rule" "SR28_instances_ingress_to_database" {
  security_group_id        = data.terraform_remote_state.delius_core_security_groups.outputs.sg_delius_db_in_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = aws_security_group.weblogic_SR28_instances.id
  description              = "SR28 in"
}

resource "aws_security_group_rule" "SR28_instances_egress_to_ldap" {
  security_group_id        = aws_security_group.weblogic_SR28_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 389
  to_port                  = 389
  source_security_group_id = data.terraform_remote_state.delius_core_security_groups.outputs.sg_apacheds_ldap_private_elb_id
  description              = "LDAP ELB out"
}
resource "aws_security_group_rule" "SR28_instances_ingress_to_ldap" {
  security_group_id        = data.terraform_remote_state.delius_core_security_groups.outputs.sg_apacheds_ldap_private_elb_id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 389
  to_port                  = 389
  source_security_group_id = aws_security_group.weblogic_SR28_instances.id
  description              = "SR28 in"
}