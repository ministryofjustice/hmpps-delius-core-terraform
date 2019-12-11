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

variable "aptracker_api_config" {
  description = "Application-specific configuration items"
  type = "map"
}

variable "default_aptracker_api_config" {
  description = "Default values to be overridden by aptracker_api_config"
  type = "map"
  default = {
    version                  = "1.11"     # Application version
    memory                   = 2048       # Memory to assign to ECS container in MB
    cpu                      = 1024       # CPU to assign to ECS container
    ecs_scaling_min_capacity = 3          # Minimum number of running tasks
    ecs_scaling_max_capacity = 30         # Maximum number of running tasks
    ecs_target_cpu           = 60         # CPU target value for scaling of ECS tasks
    log_level                = "INFO"     # Application log-level
  }
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}
