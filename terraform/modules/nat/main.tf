resource "google_compute_router" "this" {
  name    = "${var.name_prefix}-router"
  project = var.project_id
  region  = var.region
  network = var.network

  bgp {
    asn = var.bgp_asn
  }
}

resource "google_compute_router_nat" "this" {
  name                                = "${var.name_prefix}-nat"
  project                             = var.project_id
  region                              = var.region
  router                              = google_compute_router.this.name
  nat_ip_allocate_option              = var.nat_ip_allocate_option
  source_subnetwork_ip_ranges_to_nat  = var.source_subnetwork_ip_ranges_to_nat
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping
  tcp_transitory_idle_timeout_sec     = var.tcp_transitory_idle_timeout_sec
  tcp_established_idle_timeout_sec    = var.tcp_established_idle_timeout_sec

  dynamic "log_config" {
    for_each = var.log_filter != "" ? [1] : []
    content {
      enable = true
      filter = var.log_filter
    }
  }
}
