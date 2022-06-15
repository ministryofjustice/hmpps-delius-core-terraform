locals {
  # Only scale up the service in the following environments:
  target_environments = [
    "delius-core-dev",
    "delius-test",
    "delius-pre-prod",
    "delius-prod"
  ]
  min_capacity = contains(local.target_environments, var.environment_name) ? 2 : 0
  max_capacity = contains(local.target_environments, var.environment_name) ? 10 : 0
}
