variable "event_name" {
  description = "Event name string"
}

variable "event_desc" {
  description = "Description of the purpose of this event"
}

variable "event_schedule" {
  description = "Either a cron or rate schedule string"
}

variable "event_job_queue_arn" {
  description = "ARN for Job Queue to submit job to"
}

variable "event_job_def_arn" {
  description = "Job Defintiion ARN to submit job to"
}

variable "event_job_attempts" {
  description = "Retry count for failed jobs"
}

