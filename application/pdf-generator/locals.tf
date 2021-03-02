locals {
  app_name   = "pdf-generator"
  app_config = merge(var.default_pdf_generator_config, var.pdf_generator_config)
  environment = merge({ for key, value in local.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }, {
    # Add any environment variables here that should be pulled from Terraform data sources
  })
}

