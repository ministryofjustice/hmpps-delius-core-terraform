output "contact_search" {
  value = {
    arn                = aws_elasticsearch_domain.contact_search.arn
    domain_name        = aws_elasticsearch_domain.contact_search.domain_name
    endpoint           = aws_elasticsearch_domain.contact_search.endpoint
    kibana_endpoint    = aws_elasticsearch_domain.contact_search.kibana_endpoint
    availability_zones = aws_elasticsearch_domain.contact_search.vpc_options.0.availability_zones
  }
}
