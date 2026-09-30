variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for network resource names (e.g. myapp-dev)."
  type        = string
}

variable "region" {
  description = "Region for subnets."
  type        = string
}

variable "routing_mode" {
  description = "VPC routing mode (REGIONAL or GLOBAL)."
  type        = string
  default     = "GLOBAL"
}

variable "mtu" {
  description = "VPC MTU. 1460 is the safe default for GKE."
  type        = number
  default     = 1460
}

variable "subnets" {
  description = <<-EOT
    Map of subnet key => config.
    For GKE subnet, provide secondary_ranges.pods and secondary_ranges.services.
  EOT
  type = map(object({
    ip_cidr_range            = string
    private_ip_google_access = optional(bool, true)
    secondary_ranges         = optional(map(string), {})
    flow_logs                = optional(bool, true)
    flow_logs_interval       = optional(string, "INTERVAL_5_sec")
    flow_logs_sampling       = optional(number, 0.5)
    flow_logs_metadata       = optional(string, "INCLUDE_ALL_METADATA")
  }))
}

variable "labels" {
  description = "Labels applied where supported."
  type        = map(string)
  default     = {}
}
