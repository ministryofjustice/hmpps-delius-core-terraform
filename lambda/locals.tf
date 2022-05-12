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

  # Mapping from Delius environment name to Pre-Sentence Service URL
  pre_sentence_service_base_url = lookup({
    delius-test     = "https://pre-sentence-service-dev.hmpps.service.justice.gov.uk"
    delius-pre-prod = "https://pre-sentence-service-preprod.hmpps.service.justice.gov.uk"
    delius-prod     = "https://pre-sentence-service.hmpps.service.justice.gov.uk"
  }, var.environment_name, "")
}
