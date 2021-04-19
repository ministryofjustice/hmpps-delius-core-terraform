include {
  path = find_in_parent_folders()
}

dependencies {
  paths = [
    "../../alerts", "../../access-logs",
    "../../security-groups", "../../key_profile",
    "../pwm",
    "../ldap", "../../database_failover"
  ]
}