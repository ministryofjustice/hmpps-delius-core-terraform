locals {
  # Mapping from Delius environment name to Cloud Platform namespace
  cp_namespace = lookup({
    delius-test     = "dev"
    delius-pre-prod = "preprod"
    delius-prod     = "prod"
  }, var.environment_name, "")
}
