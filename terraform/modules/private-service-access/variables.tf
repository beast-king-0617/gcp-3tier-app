variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for the allocated IP range name."
  type        = string
}

variable "network" {
  description = "VPC network ID or self_link used for the service networking connection."
  type        = string
}

variable "address" {
  description = "Base address of the allocated PSA range (e.g. 10.10.100.0)."
  type        = string
}

variable "prefix_length" {
  description = "Prefix length of the allocated range (24 recommended for single Cloud SQL)."
  type        = number
  default     = 24
}

variable "address_type" {
  description = "INTERNAL for PSA."
  type        = string
  default     = "INTERNAL"
}

variable "purpose" {
  description = "VPC_PEERING for Service Networking."
  type        = string
  default     = "VPC_PEERING"
}

variable "service" {
  description = "Service producer to peer with."
  type        = string
  default     = "servicenetworking.googleapis.com"
}
