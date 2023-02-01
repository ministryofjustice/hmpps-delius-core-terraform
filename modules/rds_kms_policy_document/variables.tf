variable "environment_name" {
  type = string
}

variable "short_environment_name" {
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - eg. dlc-dev"
}

variable "aws_account_ids" {
  type = map(string)
}