locals {
  cluster_name = "${var.name_prefix}-gke"
  node_sa_id   = "gke-nodes"
}

# Least-privilege node service account (not the default Compute Engine SA).
resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = local.node_sa_id
  display_name = "GKE nodes (${var.name_prefix})"
  description  = "Node SA for ${local.cluster_name}"
}

resource "google_project_iam_member" "nodes" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

resource "google_container_cluster" "this" {
  provider = google-beta

  name     = local.cluster_name
  project  = var.project_id
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  # Create minimal default pool then remove; custom pools are authoritative.
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = var.deletion_protection

  release_channel {
    channel = var.release_channel
  }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.enable_master_authorized_networks ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  datapath_provider = var.datapath_provider

  # Dataplane V2 provides NetworkPolicy; do not enable legacy Calico alongside it.
  network_policy {
    enabled  = false
    provider = "PROVIDER_UNSPECIFIED"
  }

  gateway_api_config {
    channel = var.gateway_api_channel
  }

  dns_config {
    cluster_dns       = var.cluster_dns_provider
    cluster_dns_scope = var.cluster_dns_scope
  }

  logging_config {
    enable_components = var.logging_components
  }

  monitoring_config {
    enable_components = var.monitoring_components

    managed_prometheus {
      enabled = true
    }
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcs_fuse_csi_driver_config {
      enabled = false
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }

  # Default node config only applies to the temporary default pool.
  node_config {
    service_account = google_service_account.nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    tags = var.node_network_tags
  }

  resource_labels = var.labels

  lifecycle {
    ignore_changes = [
      # GKE mutates node_pool / node_version during upgrades.
      node_pool,
      initial_node_count,
    ]
  }

  depends_on = [google_project_iam_member.nodes]
}

resource "google_container_node_pool" "system" {
  provider = google-beta

  name     = "${var.name_prefix}-system"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.system_node_pool.min_count
    max_node_count = var.system_node_pool.max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type    = var.system_node_pool.machine_type
    disk_size_gb    = var.system_node_pool.disk_size_gb
    disk_type       = var.system_node_pool.disk_type
    spot            = var.system_node_pool.spot
    service_account = google_service_account.nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      role        = "system"
      environment = lookup(var.labels, "environment", "unknown")
    }

    taint {
      key    = "CriticalAddonsOnly"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = var.node_network_tags

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  network_config {
    enable_private_nodes = true
  }

  max_pods_per_node = var.system_node_pool.max_pods_per_node
}

resource "google_container_node_pool" "application" {
  provider = google-beta

  name     = "${var.name_prefix}-application"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.application_node_pool.min_count
    max_node_count = var.application_node_pool.max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type    = var.application_node_pool.machine_type
    disk_size_gb    = var.application_node_pool.disk_size_gb
    disk_type       = var.application_node_pool.disk_type
    spot            = var.application_node_pool.spot
    service_account = google_service_account.nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    labels = {
      role        = "application"
      environment = lookup(var.labels, "environment", "unknown")
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    tags = var.node_network_tags

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  network_config {
    enable_private_nodes = true
  }

  max_pods_per_node = var.application_node_pool.max_pods_per_node
}
