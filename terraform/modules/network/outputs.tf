output "network_name" {
  description = "VPC network name."
  value       = google_compute_network.this.name
}

output "network_id" {
  description = "VPC network self link / ID."
  value       = google_compute_network.this.id
}

output "network_self_link" {
  description = "VPC network self_link."
  value       = google_compute_network.this.self_link
}

output "subnet_ids" {
  description = "Map of subnet key => subnet ID."
  value       = { for k, v in google_compute_subnetwork.this : k => v.id }
}

output "subnet_names" {
  description = "Map of subnet key => subnet name."
  value       = { for k, v in google_compute_subnetwork.this : k => v.name }
}

output "subnet_self_links" {
  description = "Map of subnet key => self_link."
  value       = { for k, v in google_compute_subnetwork.this : k => v.self_link }
}

output "subnet_cidrs" {
  description = "Map of subnet key => primary CIDR."
  value       = { for k, v in google_compute_subnetwork.this : k => v.ip_cidr_range }
}

output "gke_pods_range_name" {
  description = "Secondary range name for GKE pods (null if gke subnet missing pods range)."
  value = try(
    [
      for r in google_compute_subnetwork.this["gke"].secondary_ip_range : r.range_name
      if r.range_name == "pods"
    ][0],
    null
  )
}

output "gke_services_range_name" {
  description = "Secondary range name for GKE services."
  value = try(
    [
      for r in google_compute_subnetwork.this["gke"].secondary_ip_range : r.range_name
      if r.range_name == "services"
    ][0],
    null
  )
}
