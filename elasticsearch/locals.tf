locals {
  contact_search_name       = "contact-search"
  contact_search_short_name = "contact-es" # Elasticsearch domain name is limited to 28 characters
  contact_search_config     = merge(var.default_contact_search_config, var.contact_search_config)
}
