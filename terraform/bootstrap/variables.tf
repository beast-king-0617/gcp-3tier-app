variable "shared_project_id" {
  description = "GCP project that hosts Terraform state and the GitHub Workload Identity Pool."
  type        = string
}

variable "region" {
  description = "Default region for regional resources (state bucket location uses var.state_bucket_location)."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Globally unique GCS bucket name for Terraform remote state."
  type        = string
}

variable "state_bucket_location" {
  description = "Location for the Terraform state bucket (use a region, e.g. us-central1)."
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "Short application name used in resource naming."
  type        = string
  default     = "myapp"
}

variable "github_organization" {
  description = "GitHub organization (or user) that owns the application/terraform repos."
  type        = string
}

variable "github_terraform_repo" {
  description = "Full GitHub repository name (org/repo) for Terraform workflows."
  type        = string
}

variable "github_application_repo" {
  description = "Full GitHub repository name (org/repo) for application CI (image build/push)."
  type        = string
}

variable "github_gitops_repo" {
  description = "Full GitHub repository name (org/repo) for GitOps manifests (optional CI updates)."
  type        = string
}

variable "environments" {
  description = <<-EOT
    Map of environment key => configuration.
    project_id must be the real GCP project ID for that environment.
  EOT
  type = map(object({
    project_id = string
  }))
}

variable "break_glass_members" {
  description = "IAM members (user: or group:) granted break-glass access to the state bucket."
  type        = list(string)
  default     = []
}

variable "enable_apis_on_environment_projects" {
  description = "If true, enable baseline APIs on each environment project during bootstrap."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}
