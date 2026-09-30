variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for firewall rule names."
  type        = string
}

variable "network" {
  description = "VPC network self_link or name."
  type        = string
}

variable "internal_source_ranges" {
  description = "CIDRs considered internal to this VPC (nodes, pods, services, mgmt, psa)."
  type        = list(string)
}

variable "gke_master_cidr" {
  description = "GKE private control-plane CIDR (/28)."
  type        = string
}

variable "gke_node_tag" {
  description = "Network tag applied to GKE nodes (Phase 4 must set the same tag)."
  type        = string
  default     = "gke-node"
}

variable "iap_ssh_tag" {
  description = "Network tag for VMs that allow IAP SSH."
  type        = string
  default     = "iap-ssh"
}

variable "enable_iap_ssh" {
  description = "Create IAP SSH allow rule."
  type        = bool
  default     = true
}

variable "health_check_ports" {
  description = "TCP ports open from Google health-check ranges to gke-node."
  type        = list(string)
  default     = ["80", "443", "8080", "15021", "10256"]
}
