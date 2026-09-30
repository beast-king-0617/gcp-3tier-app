output "allocated_range_name" {
  description = "Name of the allocated global address used for PSA."
  value       = google_compute_global_address.psa.name
}

output "allocated_ip_cidr" {
  description = "CIDR of the PSA allocated range."
  value       = "${google_compute_global_address.psa.address}/${google_compute_global_address.psa.prefix_length}"
}

output "peering_connection_id" {
  description = "Service networking connection ID."
  value       = google_service_networking_connection.psa.id
}

output "network" {
  description = "Network peered for private services."
  value       = google_service_networking_connection.psa.network
}
