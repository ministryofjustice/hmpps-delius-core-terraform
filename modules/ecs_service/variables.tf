variable "region" {
  description = "The AWS region"
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

variable "service_name" {
  description = "Name to use for this ECS service"
}

variable "ecs_cluster" {
  description = "ECS cluster details. Sould be a map with the keys 'name', 'cluster_id', 'namespace_id'."
  type        = "map"
}

variable "container_definition" {
  description = "Container definition JSON string"
  type        = "string"
}

variable "required_memory" {
  description = "Memory to assign to the container (in MB)"
}

variable "required_cpu" {
  description = "CPU units to assign to the container (1 vcpu = 1024 units)"
}

variable "required_ssm_parameters" {
  description = "List of SSM parameters to allow access to via IAM policy"
  type        = "list"
  default     = []
}

variable "service_port" {
  description = "Port to expose via the load balancer"
  default     = "8080"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnets" {
  description = "List of network subnets to assign to the tasks"
  type        = "list"
}

variable "security_groups" {
  description = "Security groups to apply to the ECS tasks"
  type        = "list"
}

variable "lb_listener_arn" {
  description = "ARN of the listener to attach service tasks to for load balancing"
  default     = ""
}

variable "lb_path_patterns" {
  description = "Load balancer path patterns to use for forwarding traffic"
  default     = ["/*"]
}

variable "lb_stickiness_enabled" {
  description = "Whether stickiness should be enabled on the load balancer"
  default     = false
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_matcher" {
  default = "200"
}

variable "health_check_timeout" {
  default = "5"
}

variable "health_check_interval" {
  default = "30"
}

variable "health_check_healthy_threshold" {
  default = "5"
}

variable "health_check_unhealthy_threshold" {
  default = "2"
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period. Increaase this if tasks are stopped before they have time to start up."
  default     = 60
}

variable "min_capacity" {
  description = "Minimum number of tasks to run at any one time"
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks to run at any one time"
  default     = 10
}

variable "target_cpu_usage" {
  description = "Target CPU usage (percentage). If the average CPU Utilization is above this value, the service will scale up. Otherwise it will scale down."
  default     = 60
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}
