variable "project_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "dns_domain" {
  description = "Base DNS domain (e.g. myapp.example.com)."
  type        = string
}

variable "create_zone" {
  description = "Create a public managed zone for dns_domain."
  type        = bool
  default     = true
}

variable "existing_zone_name" {
  description = "Existing Cloud DNS zone name when create_zone=false."
  type        = string
  default     = null
}

variable "labels" {
  type    = map(string)
  default = {}
}
