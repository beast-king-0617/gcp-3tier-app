variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "secrets" {
  description = <<-EOT
    Map of secret_id => {
      secret_data = string value (do not output this)
      labels      = optional labels
    }
    The map itself is not marked sensitive so keys can be used in for_each;
    secret_data values remain sensitive when sourced from random_password.
  EOT
  type = map(object({
    secret_data = string
    labels      = optional(map(string), {})
  }))
}

variable "replication_auto" {
  description = "Use automatic replication (recommended)."
  type        = bool
  default     = true
}
