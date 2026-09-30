variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "notification_emails" {
  description = "Email addresses for alert notifications. Empty skips channel creation; alerts still exist but notify nobody until channels are attached."
  type        = list(string)
  default     = []
}

variable "gke_cluster_name" {
  type = string
}

variable "cloudsql_instance_id" {
  description = "Cloud SQL instance name (not connection name)."
  type        = string
}

variable "enable_dashboard" {
  type    = bool
  default = true
}

variable "labels" {
  type    = map(string)
  default = {}
}
