######
# API
######

resource "aws_security_group" "merge_api" {
  name        = "${var.environment_name}-merge-api-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Merge API Security Group"
  tags        = merge(var.tags, { Name = "${var.environment_name}-merge-api-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "merge_api_out_to_merge_db" {
  security_group_id        = aws_security_group.merge_api.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = aws_security_group.merge_db.id
  description              = "Out to Merge DB"
}

resource "aws_security_group_rule" "merge_api_out_to_delius_db" {
  security_group_id        = aws_security_group.merge_api.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 1521
  to_port                  = 1521
  source_security_group_id = aws_security_group.delius_db_in.id
  description              = "Out to Delius DB"
}

resource "aws_security_group_rule" "merge_api_in_from_ndelius_lb" {
  security_group_id        = aws_security_group.merge_api.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_ndelius_lb.id
  description              = "In from NDelius LB (for healthcheck)"
}

resource "aws_security_group_rule" "merge_api_in_from_ndelius_instances" {
  security_group_id        = aws_security_group.merge_api.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 8080
  to_port                  = 8080
  source_security_group_id = aws_security_group.weblogic_ndelius_instances.id
  description              = "In from NDelius instances (for API calls)"
}

output "sg_merge_api_id" {
  value = aws_security_group.merge_api.id
}

######
# UI
######

resource "aws_security_group" "merge_ui" {
  name        = "${var.environment_name}-merge-ui-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Merge UI Security Group"
  tags        = merge(var.tags, { Name = "${var.environment_name}-merge-ui-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "merge_ui_in_from_ndelius_lb" {
  security_group_id        = aws_security_group.merge_ui.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.weblogic_ndelius_lb.id
  description              = "In from NDelius LB"
}

output "sg_merge_ui_id" {
  value = aws_security_group.merge_ui.id
}

######
# DB
######

resource "aws_security_group" "merge_db" {
  name        = "${var.environment_name}-merge-db-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Merge Database Security Group"
  tags        = merge(var.tags, { Name = "${var.environment_name}-merge-db-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "merge_db_in_from_api" {
  security_group_id        = aws_security_group.merge_db.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = aws_security_group.merge_api.id
  description              = "In from Merge API"
}

resource "aws_security_group_rule" "merge_db_in_from_bastion" {
  security_group_id = aws_security_group.merge_db.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = values(data.terraform_remote_state.vpc.outputs.bastion_vpc_public_cidr)
  description       = "In from Bastion"
}

# Necessary for data migration workflow: https://github.com/ministryofjustice/hmpps-delius-operational-automation/actions/workflows/db-migration.yml
resource "aws_security_group_rule" "merge_db_in_from_cp" {
  security_group_id = aws_security_group.gdpr_db.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_blocks       = var.cloudplatform_data.cidr_range
  description       = "In from CP"
}

output "sg_merge_db_id" {
  value = aws_security_group.merge_db.id
}

