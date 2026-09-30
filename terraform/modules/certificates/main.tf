resource "google_compute_global_address" "gateway" {
  project      = var.project_id
  name         = "${var.name_prefix}-gw-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_certificate_manager_dns_authorization" "app" {
  project  = var.project_id
  name     = "${var.name_prefix}-dnsauth"
  location = "global"
  domain   = var.hostname
  labels   = var.labels
}

# Publish the DNS authorization CNAME into Cloud DNS.
resource "google_dns_record_set" "cert_auth" {
  project      = var.project_id
  managed_zone = var.dns_zone_name
  name         = google_certificate_manager_dns_authorization.app.dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.app.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.app.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate" "app" {
  project  = var.project_id
  name     = "${var.name_prefix}-cert"
  location = "global"
  labels   = var.labels

  managed {
    domains = [var.hostname]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.app.id,
    ]
  }

  depends_on = [google_dns_record_set.cert_auth]
}

resource "google_certificate_manager_certificate_map" "app" {
  project = var.project_id
  name    = "${var.name_prefix}-certmap"
  labels  = var.labels
}

resource "google_certificate_manager_certificate_map_entry" "app" {
  project      = var.project_id
  name         = "${var.name_prefix}-certmap-entry"
  map          = google_certificate_manager_certificate_map.app.name
  certificates = [google_certificate_manager_certificate.app.id]
  hostname     = var.hostname
}

locals {
  record_name = endswith(var.hostname, ".") ? var.hostname : "${var.hostname}."
}

resource "google_dns_record_set" "app_a" {
  project      = var.project_id
  managed_zone = var.dns_zone_name
  name         = local.record_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.gateway.address]
}
