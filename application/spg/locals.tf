locals {
  # Override default values
  activemq_config = merge(var.default_activemq_config, var.activemq_config)
}

