variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "backend_k8s_namespace" {
  type    = string
  default = "backend"
}

variable "backend_k8s_service_account" {
  type    = string
  default = "backend"
}

variable "frontend_k8s_namespace" {
  type    = string
  default = "frontend"
}

variable "frontend_k8s_service_account" {
  type    = string
  default = "frontend"
}

variable "secret_ids" {
  description = "Secret Manager secret_ids the backend may read."
  type        = list(string)
  default     = []
}
