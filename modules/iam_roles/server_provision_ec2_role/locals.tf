
locals {

    engineering_account_id = contains(["delius-stage", "delius-perf", "delius-pre-prod", "delius-prod"], var.environment_name) ? var.aws_engineering_account_ids["prod"] : var.aws_engineering_account_ids["non-prod"]

    # Engineering account key is prod or non-prod, but engineering environment name is prod or dev.   Need to perform a mapping.
    engineering_account_prefix = lookup(zipmap(values(var.map), keys(var.map)), local.engineering_account_id, "non-prod") == "prod" ? "prod" : "dev"

}