locals {
  python_runtime = "python3.9"

  # Mapping from Delius environment name to Cloud Platform namespace
  cp_namespace = lookup({
    delius-test     = "dev"
    delius-pre-prod = "preprod"
    delius-prod     = "prod"
  }, var.environment_name, "")

  # Mapping from Delius environment name to HMPPS Auth URL
  oauth_base_url = lookup({
    delius-test     = "https://sign-in-dev.hmpps.service.justice.gov.uk/auth"
    delius-pre-prod = "https://sign-in-preprod.hmpps.service.justice.gov.uk/auth"
    delius-prod     = "https://sign-in.hmpps.service.justice.gov.uk/auth"
  }, var.environment_name, "")
}
