variable "ce_name" {
  description = "Name for Compute Environment"
}

variable "ce_instances" {
  description = "List of EC2 instance types to use for CE"
  type        = list(string)
}

variable "ce_min_vcpu" {
  description = "Lower bound of active VCPUs to maintain. Should be 0 in most cases"
  default     = 0
}

variable "ce_max_vcpu" {
  description = "Upper bound of active VCPUs to maintain. Must be at least as high as the largest instance type specified"
}

variable "ce_sg" {
  description = "List of Security Group IDs to attach to CE EC2 instances"
  type        = list(string)
}

variable "ce_subnets" {
  description = "List of Subnet IDs to run CE EC2 instances in. ECS instances will need outbound access for pulling images"
  type        = list(string)
}

variable "ce_tags" {
  description = "Map of tags to apply to EC2 instances operating in this CE"
  type        = map(string)
}

variable "ce_queue_state" {
  description = "State of CE job queue: ENABLED or DISABLED"
}

variable "ce_ec2_key_pair" {
  description = "EC2 key pair to launch Compute Environment instances with"
}

