resource "google_compute_global_address" "psa" {
  name          = "${var.name_prefix}-psa"
  project       = var.project_id
  purpose       = var.purpose
  address_type  = var.address_type
  address       = var.address
  prefix_length = var.prefix_length
  network       = var.network
}

resource "google_service_networking_connection" "psa" {
  network                 = var.network
  service                 = var.service
  reserved_peering_ranges = [google_compute_global_address.psa.name]
}
