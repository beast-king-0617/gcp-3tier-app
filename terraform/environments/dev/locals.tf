locals {
  name_prefix = "${var.app_name}-${var.environment}"

  labels = merge(
    {
      app         = var.app_name
      environment = var.environment
      managed-by  = "terraform"
      component   = "platform"
    },
    var.labels,
  )

  network_services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "containeranalysis.googleapis.com",
    "certificatemanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
  ]

  # Hostname patterns from Phase 1. Override via var.app_hostname if needed.
  default_hostname = var.environment == "prod" ? var.dns_domain : "${var.environment}.${var.dns_domain}"
  app_hostname     = coalesce(var.app_hostname, local.default_hostname)

  internal_source_ranges = [
    var.subnet_gke_cidr,
    var.subnet_gke_pods_cidr,
    var.subnet_gke_services_cidr,
    var.subnet_mgmt_cidr,
    "${var.psa_address}/${var.psa_prefix_length}",
  ]
}
