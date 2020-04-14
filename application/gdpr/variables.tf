variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_name" {
  description = "Environment name to be used as a unique identifier for resources - eg. delius-core-dev"
}

variable "short_environment_name" {
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - eg. dlc-dev"
}

variable "project_name" {
  description = "Project name to be used when looking up SSM parameters - eg. delius-core"
}

variable "gdpr_config" {
  description = "Application-specific configuration items"
  type = "map"
  default = {}  # Defaults are below. Keeping these as separate variables allows us to override specific config keys
                # without having to rewrite the entire map, by using the merge() function. See locals.tf.
}

variable "default_gdpr_config" {
  description = "Default values to be overridden by gdpr_config. This should match the intended config for production."
  type = "map"
  default = {
    # See https://github.com/ministryofjustice/hmpps-env-configs/blob/master/common/common.tfvars
    #     https://github.com/ministryofjustice/hmpps-env-configs/blob/master/common/common-prod.tfvars
  }
}

variable "ansible_vars" {
  description = "Ansible config - used for pulling the Alfresco host"
  type = "map"
  default = {}
}

variable "default_ansible_vars" {
  description = "Default values to be overridden by ansible_vars."
  type = "map"
  default = {}
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}
