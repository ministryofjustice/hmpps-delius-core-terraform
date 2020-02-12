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

variable "gdpr_config" {
  description = "Application-specific configuration items"
  type = "map"
  default = {}  # Defaults are below. Keeping these as separate variables allows us to override specific config keys
                # without having to rewrite the entire map, by using the merge() function. See locals.tf.
}

variable "default_gdpr_config" {
  description = "Default values to be overridden by gdpr_config"
  type = "map"
  default = {
    api_image_url            = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-gdpr"
    api_version              = "0.9"          # Application version
    api_memory               = 2048           # Memory to assign to API container
    api_cpu                  = 1024           # CPU to assign to API container
    ui_image_url             = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-gdpr-ui"
    ui_version               = "0.9"          # Application version
    ui_memory                = 2048           # Memory to assign to UI container
    ui_cpu                   = 1024           # CPU to assign to UI container
    db_instance_class        = "db.t3.small"  # Instance type to use for the database
    db_storage               = 30             # Allocated database storage in GB
    scaling_min_capacity     = 2              # Minimum number of running tasks per service
    scaling_max_capacity     = 10             # Maximum number of running tasks per service
    target_cpu               = 60             # CPU target value for scaling of ECS tasks
    log_level                = "DEBUG"        # Application log-level
  }
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}
