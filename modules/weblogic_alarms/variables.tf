variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "tier_name" {
  description = "Name of the Weblogic tier"
  type        = string
}

variable "action_arn" {
  description = "The ARN of the topic to use for alarm actions."
  type        = string
}

variable "loadbalancer_arn" {
  description = "The ARN of the WebLogic application load balancer."
  type        = string
}

variable "targetgroup_arn" {
  description = "The ARN of the WebLogic application target group."
  type        = string
}

variable "asg_name" {
  description = "The name of the WebLogic auto-scaling group."
  type        = string
}

