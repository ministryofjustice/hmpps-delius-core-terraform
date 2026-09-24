locals {
  migrated_envs = ["delius-mis-dev", "delius-test", "delius-stage", "delius-pre-prod"]
  mp_domain     = "modernisation-platform.service.justice.gov.uk"
  mp_records    = {
                    "delius-mis-dev"  = "${var.dns_name}.dev.delius-core.hmpps-development.${local.mp_domain}"
                    "delius-test"     = "${var.dns_name}.test.delius-core.hmpps-test.${local.mp_domain}"
                    "delius-stage"    = "${var.dns_name}.stage.delius-core.hmpps-preproduction.${local.mp_domain}"
                    "delius-pre-prod" = "${var.dns_name}.preprod.delius-core.hmpps-preproduction.${local.mp_domain}"
                    "delius-prod"     = "${var.dns_name}.prod.delius-core.hmpps-production.${local.mp_domain}"
                  }
  secrets       = { for key, value in var.app_config : replace(key, "secret_", "") => value if length(regexall("^secret_", key)) > 0 }
  environment   = { for key, value in var.app_config : replace(key, "env_", "") => value if length(regexall("^env_", key)) > 0 }
}

