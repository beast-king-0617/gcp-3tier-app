locals {
  gcp_health_check_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
  ]

  iap_ssh_range = "35.235.240.0/20"
}

# East-west traffic within the environment VPC (nodes, pods, services, mgmt, PSA).
# Kubernetes NetworkPolicies further restrict pod traffic in later phases.
resource "google_compute_firewall" "allow_internal" {
  name        = "${var.name_prefix}-allow-internal"
  project     = var.project_id
  network     = var.network
  description = "Allow internal VPC traffic among subnet and secondary ranges"
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = var.internal_source_ranges

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

# Google Cloud Load Balancing / Gateway health checks to GKE nodes / NEGs.
resource "google_compute_firewall" "allow_gcp_health_checks" {
  name        = "${var.name_prefix}-allow-gcp-health-checks"
  project     = var.project_id
  network     = var.network
  description = "Allow Google LB health checks to GKE nodes"
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = local.gcp_health_check_ranges
  target_tags   = [var.gke_node_tag]

  allow {
    protocol = "tcp"
    ports    = var.health_check_ports
  }
}

# Private GKE control plane to nodes (kubelet + Dataplane V2).
resource "google_compute_firewall" "allow_gke_master" {
  name        = "${var.name_prefix}-allow-gke-master"
  project     = var.project_id
  network     = var.network
  description = "Allow GKE master to communicate with nodes"
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = [var.gke_master_cidr]
  target_tags   = [var.gke_node_tag]

  allow {
    protocol = "tcp"
    ports    = ["443", "10250"]
  }

  allow {
    protocol = "udp"
    ports    = ["51820"]
  }
}

# Optional break-glass SSH via Identity-Aware Proxy (no public SSH).
resource "google_compute_firewall" "allow_iap_ssh" {
  count = var.enable_iap_ssh ? 1 : 0

  name        = "${var.name_prefix}-allow-iap-ssh"
  project     = var.project_id
  network     = var.network
  description = "Allow SSH via IAP to tagged management instances"
  priority    = 1000
  direction   = "INGRESS"

  source_ranges = [local.iap_ssh_range]
  target_tags   = [var.iap_ssh_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
