variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for router/NAT names."
  type        = string
}

variable "region" {
  description = "Region for Cloud Router and NAT."
  type        = string
}

variable "network" {
  description = "VPC network self_link or ID."
  type        = string
}

variable "nat_ip_allocate_option" {
  description = "AUTO_ONLY or MANUAL_ONLY. AUTO_ONLY is fine for v1; pin static IPs later for egress allowlists."
  type        = string
  default     = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Which subnet IP ranges to NAT."
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "enable_endpoint_independent_mapping" {
  description = "Endpoint-independent mapping (usually leave false for better scale)."
  type        = bool
  default     = false
}

variable "tcp_transitory_idle_timeout_sec" {
  description = "TCP transitory idle timeout."
  type        = number
  default     = 30
}

variable "tcp_established_idle_timeout_sec" {
  description = "TCP established idle timeout."
  type        = number
  default     = 1200
}

variable "log_filter" {
  description = "NAT log filter: ERRORS_ONLY, TRANSLATIONS_ONLY, ALL, or empty to disable."
  type        = string
  default     = "ERRORS_ONLY"
}

variable "bgp_asn" {
  description = "Router BGP ASN (private ASN range)."
  type        = number
  default     = 64514
}
