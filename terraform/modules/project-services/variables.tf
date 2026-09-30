variable "project_id" {
  description = "GCP project ID in which to enable APIs."
  type        = string
}

variable "services" {
  description = "List of Google APIs to enable (e.g. compute.googleapis.com)."
  type        = list(string)

  validation {
    condition     = length(var.services) > 0
    error_message = "At least one API service must be specified."
  }
}

variable "disable_on_destroy" {
  description = "If true, disable APIs when the Terraform resource is destroyed. Prefer false in production to avoid accidental outages."
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "If true, disable dependent services when an API is disabled."
  type        = bool
  default     = false
}
