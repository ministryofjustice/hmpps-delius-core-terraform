################################################################################
## Elasticsearch domain instances
################################################################################
resource "aws_security_group" "contact_search_domain" {
  name        = "${var.environment_name}-contact-search-domain"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Delius Contact Elasticsearch domain instances"
  tags        = merge(var.tags, { Name = "${var.environment_name}-contact-search-domain" })

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_contact_search_domain_id" {
  value = aws_security_group.contact_search_domain.id
}

resource "aws_security_group_rule" "contact_search_ingress_from_users" {
  security_group_id = aws_security_group.contact_search_domain.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = values(data.terraform_remote_state.bastion-vpc.outputs.bastion_public_cidr)
  description       = "Bastion access"
}

resource "aws_security_group_rule" "contact_search_ingress_from_delius_db" {
  security_group_id        = aws_security_group.contact_search_domain.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.delius_db_out.id
  description              = "Delius database in, for indexing"
}
