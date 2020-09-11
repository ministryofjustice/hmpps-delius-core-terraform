locals {
  # Workaround to ensure target_group.name_prefix is shorter than 6 chars.
  # Note we have to manually differentiate the name in the sandpit environment.
  tier_name_sub  = substr(var.tier_name, 0, 3)
  sandpit_prefix = "san"
  tg_name_prefix = "${var.environment_name == "delius-core-sandpit" ? local.sandpit_prefix : ""}${local.tier_name_sub}"
}

