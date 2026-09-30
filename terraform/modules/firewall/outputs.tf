output "firewall_rule_names" {
  description = "Names of managed firewall rules."
  value = compact(concat(
    [
      google_compute_firewall.allow_internal.name,
      google_compute_firewall.allow_gcp_health_checks.name,
      google_compute_firewall.allow_gke_master.name,
    ],
    var.enable_iap_ssh ? [google_compute_firewall.allow_iap_ssh[0].name] : [],
  ))
}

output "gke_node_tag" {
  description = "Network tag that Phase 4 GKE node pools must apply."
  value       = var.gke_node_tag
}

output "iap_ssh_tag" {
  description = "Network tag for IAP SSH targets."
  value       = var.iap_ssh_tag
}

output "rule_documentation" {
  description = "Human-readable rule summary for runbooks."
  value = {
    allow_internal = {
      source  = var.internal_source_ranges
      purpose = "East-west VPC traffic"
    }
    allow_gcp_health_checks = {
      source  = local.gcp_health_check_ranges
      targets = [var.gke_node_tag]
      purpose = "GCLB/Gateway health checks"
    }
    allow_gke_master = {
      source  = [var.gke_master_cidr]
      targets = [var.gke_node_tag]
      purpose = "Private GKE control plane to nodes"
    }
    allow_iap_ssh = {
      enabled = var.enable_iap_ssh
      source  = [local.iap_ssh_range]
      targets = [var.iap_ssh_tag]
      purpose = "Break-glass SSH via IAP"
    }
  }
}
