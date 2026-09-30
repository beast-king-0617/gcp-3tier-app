variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for cluster and node pool names (e.g. myapp-dev)."
  type        = string
}

variable "region" {
  description = "Region for the regional cluster."
  type        = string
}

variable "network" {
  description = "VPC network self_link."
  type        = string
}

variable "subnetwork" {
  description = "GKE subnet self_link."
  type        = string
}

variable "pods_range_name" {
  description = "Secondary range name for pods."
  type        = string
}

variable "services_range_name" {
  description = "Secondary range name for services."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "Private GKE control-plane CIDR (/28)."
  type        = string
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "enable_private_endpoint" {
  description = "If true, master has no public endpoint (access via private IP / Connect Gateway only)."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "CIDRs allowed to reach the public control-plane endpoint. Empty with authorized networks enabled locks down public access."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_master_authorized_networks" {
  description = "Restrict public master endpoint by CIDR."
  type        = bool
  default     = true
}

variable "datapath_provider" {
  description = "ADVANCED_DATAPATH enables Dataplane V2."
  type        = string
  default     = "ADVANCED_DATAPATH"
}

variable "gateway_api_channel" {
  description = "Gateway API channel: CHANNEL_STANDARD, CHANNEL_DISABLED, or CHANNEL_EXPERIMENTAL."
  type        = string
  default     = "CHANNEL_STANDARD"
}

variable "cluster_dns_provider" {
  description = "DNS provider: CLOUD_DNS or PROVIDER_UNSPECIFIED."
  type        = string
  default     = "CLOUD_DNS"
}

variable "cluster_dns_scope" {
  description = "DNS scope: CLUSTER_SCOPE or VPC_SCOPE."
  type        = string
  default     = "CLUSTER_SCOPE"
}

variable "logging_components" {
  description = "GKE logging components."
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS", "WORKLOADS"]
}

variable "monitoring_components" {
  description = "GKE monitoring components."
  type        = list(string)
  default     = ["SYSTEM_COMPONENTS", "STORAGE", "HPA", "POD", "DAEMONSET", "DEPLOYMENT", "STATEFULSET", "CADVISOR", "KUBELET"]
}

variable "maintenance_start_time" {
  description = "RFC3339 daily/weekly maintenance window start (UTC). Example: 2025-01-05T05:00:00Z for Sundays-ish recurrence."
  type        = string
  default     = "2025-01-05T05:00:00Z"
}

variable "maintenance_end_time" {
  description = "RFC3339 maintenance window end."
  type        = string
  default     = "2025-01-05T09:00:00Z"
}

variable "maintenance_recurrence" {
  description = "RRULE for maintenance window."
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SU"
}

variable "node_network_tags" {
  description = "Network tags applied to all node pools (must include firewall gke-node tag)."
  type        = list(string)
  default     = ["gke-node"]
}

variable "system_node_pool" {
  description = "System node pool configuration."
  type = object({
    machine_type      = string
    min_count         = number
    max_count         = number
    disk_size_gb      = optional(number, 50)
    disk_type         = optional(string, "pd-balanced")
    spot              = optional(bool, false)
    max_pods_per_node = optional(number, 64)
  })
}

variable "application_node_pool" {
  description = "Application node pool configuration."
  type = object({
    machine_type      = string
    min_count         = number
    max_count         = number
    disk_size_gb      = optional(number, 100)
    disk_type         = optional(string, "pd-balanced")
    spot              = optional(bool, false)
    max_pods_per_node = optional(number, 64)
  })
}

variable "labels" {
  description = "Labels applied to the cluster."
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Prevent accidental cluster deletion."
  type        = bool
  default     = false
}
