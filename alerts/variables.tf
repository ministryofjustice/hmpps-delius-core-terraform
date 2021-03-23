variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_name" {
  description = "Environment name to be used as a unique identifier for resources - eg. delius-core-dev"
}

variable "delius_alarms_config" {
  type = object({
    enabled     = bool
    quiet_hours = tuple([number, number])
  })
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

