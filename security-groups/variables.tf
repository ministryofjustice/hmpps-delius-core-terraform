variable "region" {
  description = "The AWS region"
}

variable "project_name" {
  description = "The project name - delius-core"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "tags" {
  type        = "map"
  description = "Default tag set"
}

variable "whitelist_cidrs" {
  type        = "list"
  description = "Permitted ingress from the internet"
}