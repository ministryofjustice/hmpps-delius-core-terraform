variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "region" {
  description = "The AWS region."
}

variable "environment_name" {
  description = "Environment name."
}

variable "pingdom_publicreports" {
  type        = "list"
  description = "A list of reports that should be made public on pingdom.service.dsd.io"
  default     = []
}

variable "pingdom_user" {
  description = "Email address for the pingdom user"
}

variable "pingdom_password" {
  description = "Password for the pingdom user"
}

variable "pingdom_api_key" {
  description = "App key to be used when calling the pingdom API"
}

variable "pingdom_account_email" {
  description = "Email address for the account admin. Only required for multi-user accounts"
}
