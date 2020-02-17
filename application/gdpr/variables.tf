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
  description = "Default values to be overridden by gdpr_config. This should match the intended config for production."
  type = "map"
  default = {
    api_image_url               = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-gdpr"
    api_version                 = "0.11"                 # Application version
    api_memory                  = 4196                   # Memory to assign to API container
    api_cpu                     = 2048                   # CPU to assign to API container
    cron_identifyduplicates     = "-"                    # Batch schedules. Set to "-" to disable.
    cron_retainedoffenders      = "-"                    #
    cron_retainedoffendersiicsa = "-"                    #
    cron_eligiblefordeletion    = "-"                    #
    cron_deleteoffenders        = "-"                    #
    cron_destructionlogclearing = "-"                    #
    ui_image_url                = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-gdpr-ui"
    ui_version                  = "0.11"                 # Application version
    ui_memory                   = 1024                   # Memory to assign to UI container
    ui_cpu                      = 1024                   # CPU to assign to UI container
    db_instance_class           = "db.m5.large"          # Instance type to use for the database
    db_storage                  = 100                    # Allocated database storage in GB
    db_maintenance_window       = "Wed:21:00-Wed:23:00"  # Maintenance window for database patching/upgrades
    db_backup_window            = "19:00-21:00"          # Daily window to take RDS backups
    db_backup_retention_period  = 14                     # Number of days to retain RDS backups for
    scaling_min_capacity        = 2                      # Minimum number of running tasks per service
    scaling_max_capacity        = 10                     # Maximum number of running tasks per service
    target_cpu                  = 60                     # CPU target value for scaling of ECS tasks
    log_level                   = "INFO"                 # Application log-level
  }

variable "tags" {
  description = "Tags to be applied to resources"
  type        = "map"
}
