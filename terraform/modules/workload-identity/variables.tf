variable "project_id" {
  description = "GCP project that hosts the Workload Identity Pool (typically the shared project)."
  type        = string
}

variable "pool_id" {
  description = "Workload Identity Pool ID (short name)."
  type        = string
  default     = "github-actions"
}

variable "pool_display_name" {
  description = "Human-readable pool display name."
  type        = string
  default     = "GitHub Actions"
}

variable "pool_description" {
  description = "Pool description."
  type        = string
  default     = "Workload Identity Pool for GitHub Actions OIDC"
}

variable "provider_id" {
  description = "Workload Identity Provider ID (short name)."
  type        = string
  default     = "github"
}

variable "provider_display_name" {
  description = "Provider display name."
  type        = string
  default     = "GitHub OIDC"
}

variable "github_organization" {
  description = "GitHub organization (or user) name used in the provider attribute condition."
  type        = string
}

variable "allowed_repositories" {
  description = "Optional list of full repository names (org/repo). If empty, provider condition allows any repo under the organization."
  type        = list(string)
  default     = []
}

variable "issuer_uri" {
  description = "OIDC issuer URI for GitHub Actions."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "attribute_mapping" {
  description = "OIDC attribute mapping for the GitHub provider."
  type        = map(string)
  default = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
    "attribute.aud"              = "assertion.aud"
  }
}

variable "service_account_bindings" {
  description = <<-EOT
    Map of unique binding key => {
      service_account_email = Google SA email to impersonate
      repository            = Full GitHub repo name (org/repo) allowed to impersonate
    }
  EOT
  type = map(object({
    service_account_email = string
    repository            = string
  }))
  default = {}
}
