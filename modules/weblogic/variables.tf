variable "admin_instance_type" {
  description = "Instance type for the admin server"
  type = "string"
}

variable "managed_instance_type" {
  description = "Instance type for the managed server"
  type = "string"
}

variable "admin_security_groups" {
  description = "Security groups for the admin server"
  type = "list"
}

variable "managed_security_groups" {
  description = "Security groups for the managed server"
  type = "list"
}

variable "private_subnet" {
  description = "Subnet for the servers"
  type = "string"
}

variable "public_subnets" {
  description = "Subnet for load balancers"
  type = "list"
}

variable "tags" {
  description = "Tags to match tagging standard"
  type = "map"
}

variable "environment_name" {
  description = "Name of the environment"
  type = "string"
}

variable "dns_zone_id" {
  description = "ID for the top level zone for the project"
  type = "string"
}

variable "elb_sg_id" {
  description = "ID for the security group for the ELB"
  type = "string"
}

variable "managed_port" {
  description = "TCP port for the managed server"
  type = "string"
}

variable "admin_port" {
  description = "TCP port for the admin server"
  type = "string"
}

variable "tier_name" {
  description = "Name of the Weblogic tier"
  type = "string"
}