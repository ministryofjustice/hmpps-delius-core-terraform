################################################################################
## Load balancer
################################################################################
resource "aws_security_group" "delius_api_lb" {
  name        = "${var.environment_name}-delius-api-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Delius API load balancer"
  tags        = merge(var.tags, { Name = "${var.environment_name}-delius-api-lb" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_api_lb_id" {
  value = aws_security_group.delius_api_lb.id
}

resource "aws_security_group_rule" "delius_api_lb_from_internal_users" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.delius_api_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = each.value
  to_port           = each.value
  cidr_blocks       = concat(local.bastion_public_ip, var.internal_moj_access_cidr_blocks, local.natgateway_public_ips_cidr_blocks)
  description       = "In from allowed IP ranges on port ${each.value}"
}

resource "aws_security_group_rule" "delius_api_lb_from_pre_sentence_report_handler" {
  security_group_id        = aws_security_group.delius_api_lb.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.pre_sentence_report_lambda.id
  description              = "In from pre-sentence report lambda"
}

resource "aws_security_group_rule" "delius_api_lb_to_instances" {
  security_group_id        = aws_security_group.delius_api_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.delius_api_instances.id
  description              = "Out to Delius API instances"
}

################################################################################
## Public / unrestricted Load balancer (for exposing documentation)
################################################################################
resource "aws_security_group" "delius_api_public_lb" {
  name        = "${var.environment_name}-delius-api-public-lb"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Delius API public / unrestricted access"
  tags        = merge(var.tags, { Name = "${var.environment_name}-delius-api-public-lb" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_api_public_lb_id" {
  value = aws_security_group.delius_api_public_lb.id
}

resource "aws_security_group_rule" "delius_api_public_lb_from_everywhere" {
  security_group_id = aws_security_group.delius_api_public_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "In from everywhere"
}

resource "aws_security_group_rule" "delius_api_public_lb_to_instances" {
  security_group_id        = aws_security_group.delius_api_public_lb.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.delius_api_instances.id
  description              = "Out to Delius API instances"
}

################################################################################
## Instances
################################################################################
resource "aws_security_group" "delius_api_instances" {
  name        = "${var.environment_name}-delius-api-instances"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Delius API instances"
  tags        = merge(var.tags, { Name = "${var.environment_name}-delius-api-instances" })
  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_api_instances_id" {
  value = aws_security_group.delius_api_instances.id
}

resource "aws_security_group_rule" "delius_api_instances_from_lb" {
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.delius_api_lb.id
  description              = "In from Delius API load balancer"
}

resource "aws_security_group_rule" "delius_api_instances_from_public_lb" {
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.delius_api_public_lb.id
  description              = "In from public Delius API load balancer"
}

resource "aws_security_group_rule" "delius_api_instances_from_delius_ui" {
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_ndelius_instances.id
  description              = "In from Delius UI"
}

resource "aws_security_group_rule" "delius_api_instances_from_community_api" {
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.community_api_instances.id
  description              = "In from Community API"
}

resource "aws_security_group_rule" "delius_api_instances_to_db" {
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Out to Delius Database"
}

resource "aws_security_group_rule" "delius_api_instances_to_elasticsearch" {
  security_group_id        = aws_security_group.delius_api_instances.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.contact_search_domain.id
  description              = "Out to Elasticsearch"
}
