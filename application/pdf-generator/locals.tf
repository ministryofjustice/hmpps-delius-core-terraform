locals {
  app_name   = "pdf-generator"
  app_config = merge(var.default_pdf_generator_config, var.pdf_generator_config)
}

