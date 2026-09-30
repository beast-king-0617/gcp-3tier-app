variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "chart_version" {
  type    = string
  default = "0.10.5"
}

variable "namespace" {
  type    = string
  default = "external-secrets"
}

variable "secret_ids" {
  description = "Secret Manager secret_ids ESO may read."
  type        = list(string)
}
