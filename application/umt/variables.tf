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
  default = {
    version = "latest"              # Application version
    instance_type = "t3.large"      # AWS instance type to use
    memory = 6144                   # Memory to assign to ECS container in MB
    ecs_scaling_min_capacity = 3    # Minimum number of running tasks
    ecs_scaling_max_capacity = 30   # Maximum number of running tasks
    ec2_scaling_min_capacity = 3    # Minimum number of running instances
    ec2_scaling_max_capacity = 30   # Maximum number of running instances
    ecs_target_cpu = 60             # CPU target value for scaling of ECS tasks
    scale_up_cpu_threshold = 50     # CPU threshold to trigger scale up of EC2 instances
    scale_down_cpu_threshold = 15   # CPU threshold to trigger scale down of EC2 instances
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