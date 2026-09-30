locals {
  zone_dns_name = endswith(var.dns_domain, ".") ? var.dns_domain : "${var.dns_domain}."
}

resource "google_dns_managed_zone" "public" {
  count = var.create_zone ? 1 : 0

  project     = var.project_id
  name        = replace("${var.name_prefix}-public", ".", "-")
  dns_name    = local.zone_dns_name
  description = "Public DNS zone for ${var.dns_domain}"
  visibility  = "public"
  labels      = var.labels

  dnssec_config {
    state = "on"
  }
}

data "google_dns_managed_zone" "existing" {
  count   = var.create_zone ? 0 : 1
  project = var.project_id
  name    = var.existing_zone_name
}

locals {
  zone_name = var.create_zone ? google_dns_managed_zone.public[0].name : data.google_dns_managed_zone.existing[0].name
}
