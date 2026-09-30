variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "location" {
  description = "Artifact Registry location (region)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for repository IDs (e.g. myapp-dev)."
  type        = string
}

variable "repositories" {
  description = "Map of short name => repository config. Repo ID becomes {name_prefix}-{key}."
  type = map(object({
    description    = optional(string, "")
    immutable_tags = optional(bool, false)
  }))
  default = {
    frontend = {
      description = "Frontend container images"
    }
    backend = {
      description = "Backend container images"
    }
  }
}

variable "labels" {
  description = "Labels applied to repositories."
  type        = map(string)
  default     = {}
}

variable "writer_members" {
  description = "IAM members granted roles/artifactregistry.writer on each repository."
  type        = list(string)
  default     = []
}

variable "reader_members" {
  description = "IAM members granted roles/artifactregistry.reader on each repository."
  type        = list(string)
  default     = []
}

variable "enable_cleanup_policy" {
  description = "Enable cleanup policy to retain only recent versions."
  type        = bool
  default     = true
}

variable "keep_version_count" {
  description = "Number of recent versions to keep when cleanup is enabled."
  type        = number
  default     = 20
}

variable "enable_vulnerability_scanning" {
  description = "Enable Artifact Analysis vulnerability scanning on push."
  type        = bool
  default     = true
}
