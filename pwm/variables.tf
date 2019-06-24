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

variable "pwm_config" {
  description = "Application-specific configuration items"
  type = "map"
  default = {
    instance_type = "t3.large"  # AWS instance type to use
    desired_count = 2           # Initial number of EC2 instances to use
    memory = 6144               # Memory to assign to ECS container in MB
  }
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}