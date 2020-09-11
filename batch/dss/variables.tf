variable "environment_name" {
  type = string
}

variable "short_environment_name" {
  type = string
}

variable "project_name" {
  description = "The project name - delius-core"
}

variable "environment_type" {
  description = "The environment type - e.g. dev"
}

variable "region" {
  description = "The AWS region."
}

variable "remote_state_bucket_name" {
  description = "Terraform remote state bucket name"
}

variable "environment_identifier" {
  description = "resource label or name"
}

variable "short_environment_identifier" {
  description = "shortend resource label or name"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "tags" {
  type = map(string)
}

variable "dss_batch_instances" {
  description = "List of permitted EC2 instance types to use for AWS Batch compute Environment"
  type        = list(string)
}

variable "dss_max_vcpu" {
  description = "Upper bound for active VCPUs in the AWS Batch Compute Environment. Must be >= VCPU count of largest instance type specified in dss_batch_instances"
}

variable "dss_min_vcpu" {
  description = "Lower bound for active VCPUs in the AWS Batch Compute Environment. 0 means env will be scaled down when not required"
}

variable "dss_job_image" {
  description = "DSS Docker Image"
}

variable "dss_job_vcpus" {
  description = "No. of VCPUs to assign to the DSS scheduled job"
}

variable "dss_job_memory" {
  description = "Amount of RAM (GB) to assign to the DSS scheduled job"
}

variable "dss_job_retries" {
  description = "Number of retries for a failed DSS job"
}

variable "dss_job_envvars" {
  description = "List of aps of Environment Variables to pass to DSS batch job"
  type        = list(map(string))
}

variable "dss_job_ulimits" {
  description = "List of maps for ulimit values for DSS batch job definition"
  type        = list(map(string))
}

variable "dss_queue_state" {
  description = "State of the DSS Batch Queue: ENABLED or DISABLED"
}

variable "dss_job_schedule" {
  description = "cron or rate expression for Cloudwatch Event Rule schedule"
}

