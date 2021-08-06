variable "region" {
  description = "The AWS region"
  type        = string
}

variable "environment_name" {
  description = "Environment name - e.g. delius-core-dev"
  type        = string
}

variable "short_environment_name" {
  description = "Shortened environment name to be used as a unique identifier for resources with a limit on resource name length - e.g. dlc-dev"
  type        = string
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
  type        = string
}

variable "service_name" {
  description = "Name to use for this ECS service"
  type        = string
}

variable "container_definitions" {
  description = "List of containers to run in ECS tasks. When a single container is defined, sensible configuration defaults are added to the definition - for example, logging (see ecs.tf)."
  type        = list(any)
}

variable "additional_log_files" {
  description = "Additional log files inside the container to be pushed to CloudWatch Logs, using the sidecar logging pattern."
  type        = map(string)
  default     = {}
}

variable "memory" {
  description = "Memory to assign to the container (in MB)"
  default     = 2048
}

variable "cpu" {
  description = "CPU units to assign to the container (1 vcpu = 1024 units)"
  default     = 1024
}

variable "environment" {
  description = "Map of environment variables to be set in the service container."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of environment variables that should be pulled from SSM parameter store, as parameter paths."
  type        = map(string)
  default     = {}
}

variable "service_port" {
  description = "Port to expose via the load balancer"
  type        = number
  default     = 8080
}

variable "security_groups" {
  description = "Security groups to apply to the ECS tasks"
  type        = list(string)
}

variable "deployment_controller" {
  description = "Type of deployment controller. Valid values are CODE_DEPLOY, ECS, EXTERNAL. Defaults to ECS."
  default     = "ECS"
}

variable "target_group_count" {
  description = "Number of target groups to create. Set to 2 to enable blue/green deployment. Defaults to 1."
  default     = 1
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

variable "lb_algorithm_type" {
  description = "Corresponds to the load_balancing_algorithm_type setting on the automatically-created target groups. Determines the how the load balancer selects targets when routing requests. The value is round_robin or least_outstanding_requests."
  default     = "round_robin"
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_matcher" {
  default = 200
}

variable "health_check_timeout" {
  default = 5
}

variable "health_check_interval" {
  default = 30
}

variable "health_check_healthy_threshold" {
  default = 5
}

variable "health_check_unhealthy_threshold" {
  default = 2
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period. Increase this if tasks are stopped before they have time to start up."
  default     = 300
}

variable "min_capacity" {
  description = "Minimum number of tasks to run at any one time"
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks to run at any one time"
  default     = 10
}

variable "enable_cpu_scaling" {
  description = "Whether to scale the service based on CPU usage."
  default     = true
}

variable "target_cpu_usage" {
  description = "Target CPU usage (percentage). If the average CPU Utilization is above this value, the service will scale up. Otherwise it will scale down."
  default     = 60
}

variable "enable_mem_scaling" {
  description = "Whether to scale the service based on Memory usage."
  default     = false
}

variable "target_mem_usage" {
  description = "Target memory usage (percentage). If the average Memory Utilization is above this value, the service will scale up. Otherwise it will scale down."
  default     = 60
}

variable "disable_scale_in" {
  description = "Indicates whether scale in by the target tracking policy is disabled. Useful for stateful services where scale in needs to be carefully controlled. Defaults to false."
  default     = false
}

variable "placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. Defaults to AZ-balanced binpack. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-placement-strategies.html"
  type = list(object({
    field = string
    type  = string
  }))
  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "binpack"
      field = "memory"
    }
  ]
}

variable "deregistration_delay" {
  description = "Number of seconds to spend draining tasks"
  default     = 60
}

variable "ignore_task_definition_changes" {
  description = "Whether to ignore changes to the registered task definition for the service. Useful for externally-managed deployments."
  default     = false
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain CloudWatch log events for the service. Only used when no 'logConfiguration' block is provided in var.container_definitions. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  default     = 365
}

variable "log_error_pattern" {
  description = "Pattern to search for in the logs to indicate service errors. By default, no log filtering is performed."
  default     = ""
}

variable "notification_arn" {
  description = "ARN of an SNS topic to send alarm notifications to. By default, no alarms are created."
  default     = ""
}

variable "create_lb_alarms" {
  description = "Whether to create alarms for response times and error counts."
  default     = false
}

variable "load_balancer_arn" {
  description = "ARN of the service's load balancer, if there is one. Required for alerting on response times and error counts."
  default     = ""
}

variable "enable_response_code_alarms" {
  description = "Enable or disable standard alarms for 5xx responses. Only used when load-balancer alarms are created (`var.create_lb_alarms`)."
  default     = true
}

variable "enable_response_time_alarms" {
  description = "Enable or disable standard alarms for response times. Only used when load-balancer alarms are created (`var.create_lb_alarms`)."
  default     = true
}

variable "enable_healthy_host_alarms" {
  description = "Enable or disable standard alarms for the number of healthy instances. Only used when load-balancer alarms are created (`var.create_lb_alarms`)."
  default     = true
}

variable "enable_jmx_metrics" {
  description = "Enable the JMX Exporter for Java/JVM-based applications, to push internal metrics to Prometheus/CloudWatch. Set to true to mount the /jmx-exporter volume onto the container and to update the JAVA_TOOL_OPTIONS environment variable to enable instrumentation."
  default     = false
}

variable "jmx_exporter_config" {
  description = "Location of the jmx-exporter config file inside the container. By default, a standard config file will be mounted into the container and used."
  default     = "/jmx-exporter/config.yaml"
}

variable "enable_telemetry" {
  description = "Enable AWS Open Telemetry Collector. Set to true to run the Telemetry daemon as a sidecar container, and to mount the /xray-agent volume onto the container. The JAVA_TOOL_OPTIONS environment variable is then used to instrument the Java application with the mounted agent library - use `var.telemetry_use_java_tool_opts` to change this behaviour."
  default     = false
}

variable "telemetry_use_java_tool_opts" {
  description = "Whether to use the the JAVA_TOOL_OPTS environment variable for auto-instrumenting Java services with the AWS OpenTelemetry Agent. This is only used when Telemetry is enabled (`var.enable_telemetry`)."
  default     = true
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

