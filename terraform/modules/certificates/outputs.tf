output "gateway_ip_name" {
  description = "Global address resource name for Gateway annotation networking.gke.io/addresses."
  value       = google_compute_global_address.gateway.name
}

output "gateway_ip_address" {
  description = "Reserved IPv4 for the Gateway / DNS A record."
  value       = google_compute_global_address.gateway.address
}

output "certificate_map_name" {
  description = "Certificate map name for Gateway annotation networking.gke.io/certmap."
  value       = google_certificate_manager_certificate_map.app.name
}

output "certificate_name" {
  value = google_certificate_manager_certificate.app.name
}

output "hostname" {
  value = var.hostname
}

output "a_record_fqdn" {
  value = google_dns_record_set.app_a.name
}
