locals {
  python_runtime = "python3.9"
  nodejs_runtime = "nodejs14.x" # bump to 16.x when https://github.com/hashicorp/terraform-provider-aws/issues/24793 is available

  # Mapping from Delius environment name to Cloud Platform namespace
  cp_namespace = lookup({
    delius-test     = "dev"
    delius-pre-prod = "preprod"
    delius-prod     = "prod"
  }, var.environment_name, "")

  # HMPPS Auth URL
  oauth_base_url = lookup({
    delius-test     = "https://sign-in-dev.hmpps.service.justice.gov.uk/auth"
    delius-pre-prod = "https://sign-in-preprod.hmpps.service.justice.gov.uk/auth"
    delius-prod     = "https://sign-in.hmpps.service.justice.gov.uk/auth"
  }, var.environment_name, "")

  # Pre-Sentence Service URLs
  pre_sentence_service_base_url = lookup({
    delius-test     = "https://pre-sentence-service-dev.hmpps.service.justice.gov.uk"
    delius-pre-prod = "https://pre-sentence-service-preprod.hmpps.service.justice.gov.uk"
    delius-prod     = "https://pre-sentence-service.hmpps.service.justice.gov.uk"
  }, var.environment_name, "")

  # HMPPS Workload Service URLs
  workload_service_base_url = lookup({
    delius-test     = "https://hmpps-workload-dev.hmpps.service.justice.gov.uk"
    delius-pre-prod = "https://hmpps-workload-preprod.hmpps.service.justice.gov.uk"
    delius-prod     = "https://hmpps-workload.hmpps.service.justice.gov.uk"
  }, var.environment_name, "")
}
