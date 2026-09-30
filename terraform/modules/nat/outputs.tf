output "router_name" {
  description = "Cloud Router name."
  value       = google_compute_router.this.name
}

output "router_id" {
  description = "Cloud Router ID."
  value       = google_compute_router.this.id
}

output "nat_name" {
  description = "Cloud NAT name."
  value       = google_compute_router_nat.this.name
}

output "nat_id" {
  description = "Cloud NAT ID."
  value       = google_compute_router_nat.this.id
}
