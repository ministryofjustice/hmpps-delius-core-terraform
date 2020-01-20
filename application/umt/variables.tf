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

variable "umt_config" {
  description = "Application-specific configuration items"
  type = "map"
}

variable "default_umt_config" {
  description = "Default values to be overridden by umt_config"
  type = "map"
  default = {
    version                       = "1.6.6"           # Application version
    memory                        = 2048              # Memory to assign to ECS container in MB
    cpu                           = 1024              # CPU to assign to ECS container
    ecs_scaling_min_capacity      = 3                 # Minimum number of running tasks
    ecs_scaling_max_capacity      = 30                # Maximum number of running tasks
    ecs_target_cpu                = 60                # CPU target value for scaling of ECS tasks
    redis_node_type               = "cache.m5.large"  # Instance type to use for the Redis token store cluster
    redis_node_groups             = 4                 # Number of Redis shards (node groups) in the cluster
    redis_replicas_per_node_group = 1                 # Number of read-only replicas for each shard (node group)
  }
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}

variable "default_ansible_vars" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars"
  type        = "map"
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = "map"
}