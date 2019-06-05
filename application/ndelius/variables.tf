variable "environment_name" {
  type = "string"
}

variable "short_environment_name" {
  type = "string"
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

variable "weblogic_domain_ports" {
  type        = "map"
  description = "Map of the ports that the weblogic domains use"
}

variable "instance_type_weblogic" {
  description = "The ec2 instance type"
}

variable "instance_count_weblogic_ndelius" {
  description = "The desired number of weblogic instances"
}

variable "dependencies_bucket_arn" {
  description = "S3 bucket arn for dependencies"
}

variable "default_ansible_vars" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars"
  type        = "map"
}

variable "ansible_vars" {
  description = "Ansible vars for user_data script"
  type        = "map"
}

variable "ansible_vars_apacheds" {
  description = "Ansible (ldap) vars for user_data script "
  type        = "map"
}

variable "default_ansible_vars_apacheds" {
  description = "Default ansible vars for user_data script, will be overriden by values in ansible_vars_apacheds"
  type        = "map"
}

variable "ldap_ports" {
  type        = "map"
  description = "Map of the ports that the ldap ports"
}

variable "tags" {
  type = "map"
}

variable "dss_batch_instances" {
  description = "List of permitted EC2 instance types to use for AWS Batch compute Environment"
  type        = "list"
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
  description = "Map of Environment Variables to pass to DSS batch job"
  type        = "map"
}

variable "dss_job_ulimits" {
  description = "Map of ulimit values for DSS batch job definition"
  type        = "map"
}

variable "dss_queue_state" {
  description = "State of the DSS Batch Queue: ENABLED or DISABLED"
}

variable "dss_job_schedule" {
  description = "cron or rate expression for Cloudwatch Event Rule schedule"
}
