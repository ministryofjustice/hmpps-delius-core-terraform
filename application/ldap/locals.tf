locals {
  # Override default values
  ansible_vars_apacheds = "${merge(var.default_ansible_vars_apacheds, var.ansible_vars_apacheds)}"
}
