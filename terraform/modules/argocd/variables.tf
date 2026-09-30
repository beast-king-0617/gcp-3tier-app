variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "environment" {
  description = "Environment name (dev|stage|prod) — selects GitOps path."
  type        = string
}

variable "chart_version" {
  description = "Argo CD Helm chart version."
  type        = string
  default     = "7.7.16"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "git_repo_url" {
  description = "Git repository URL containing the gitops/ directory."
  type        = string
}

variable "git_target_revision" {
  description = "Git branch/tag/commit for Argo CD to track."
  type        = string
  default     = "develop"
}

variable "gitops_path" {
  description = "Path inside the repo for this environment overlay. Null => gitops/environments/<environment>."
  type        = string
  default     = null
}

variable "bootstrap_application" {
  description = "Create the Argo CD Application that syncs the environment overlay."
  type        = bool
  default     = true
}

variable "server_insecure" {
  description = "Disable TLS on argocd-server for initial bootstrap behind IAP/Gateway later. Prefer false in prod with proper certs."
  type        = bool
  default     = true
}
