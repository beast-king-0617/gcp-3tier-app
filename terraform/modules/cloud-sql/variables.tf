variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for instance and secret names (e.g. myapp-dev)."
  type        = string
}

variable "region" {
  description = "Cloud SQL region."
  type        = string
}

variable "network_id" {
  description = "VPC network ID for private IP (projects/.../global/networks/...)."
  type        = string
}

variable "database_version" {
  description = "Cloud SQL Postgres version."
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine tier (e.g. db-custom-1-3840)."
  type        = string
}

variable "availability_type" {
  description = "ZONAL or REGIONAL (HA)."
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "availability_type must be ZONAL or REGIONAL."
  }
}

variable "disk_size_gb" {
  description = "Initial disk size in GB."
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "PD_SSD or PD_HDD."
  type        = string
  default     = "PD_SSD"
}

variable "disk_autoresize" {
  description = "Enable automatic storage increase."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Max disk size GB for autoresize (0 = no limit)."
  type        = number
  default     = 0
}

variable "edition" {
  description = "ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE"
}

variable "deletion_protection" {
  description = "Prevent instance deletion."
  type        = bool
  default     = true
}

variable "backup_enabled" {
  description = "Enable automated backups."
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable PITR (requires backups)."
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM UTC start for backup window."
  type        = string
  default     = "03:00"
}

variable "transaction_log_retention_days" {
  description = "PITR log retention days."
  type        = number
  default     = 7
}

variable "retained_backups" {
  description = "Number of retained automated backups."
  type        = number
  default     = 7
}

variable "maintenance_day" {
  description = "Day of week for maintenance (1=Monday ... 7=Sunday)."
  type        = number
  default     = 7
}

variable "maintenance_hour" {
  description = "Hour of day UTC for maintenance (0-23)."
  type        = number
  default     = 5
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "myapp"
}

variable "database_user" {
  description = "Application database user."
  type        = string
  default     = "myapp"
}

variable "database_flags" {
  description = "Optional database flags. Only set when required."
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "log_checkpoints"
      value = "on"
    },
    {
      name  = "log_lock_waits"
      value = "on"
    }
  ]
}

variable "query_insights_enabled" {
  description = "Enable Query Insights."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels for the instance."
  type        = map(string)
  default     = {}
}

variable "password_length" {
  description = "Generated password length."
  type        = number
  default     = 32
}
