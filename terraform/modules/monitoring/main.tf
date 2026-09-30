locals {
  channel_ids = [for c in google_monitoring_notification_channel.email : c.id]

  # Low-noise defaults: sustained breach windows, not instantaneous spikes.
  alert_policies = {
    gke_node_cpu = {
      display_name  = "${var.name_prefix} GKE node CPU high"
      documentation = "Node CPU allocatable utilization > 85% for 15m."
      combiner      = "OR"
      conditions = [{
        display_name    = "Node CPU > 85%"
        filter          = <<-EOT
          resource.type = "k8s_node"
          AND resource.labels.cluster_name = "${var.gke_cluster_name}"
          AND metric.type = "kubernetes.io/node/cpu/allocatable_utilization"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 0.85
        duration        = "900s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }

    gke_node_memory = {
      display_name  = "${var.name_prefix} GKE node memory high"
      documentation = "Node memory allocatable utilization > 90% for 15m."
      combiner      = "OR"
      conditions = [{
        display_name    = "Node memory > 90%"
        filter          = <<-EOT
          resource.type = "k8s_node"
          AND resource.labels.cluster_name = "${var.gke_cluster_name}"
          AND metric.type = "kubernetes.io/node/memory/allocatable_utilization"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 0.90
        duration        = "900s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }

    gke_container_cpu = {
      display_name  = "${var.name_prefix} container CPU high"
      documentation = "Container CPU limit utilization > 90% for 15m."
      combiner      = "OR"
      conditions = [{
        display_name    = "Container CPU > 90%"
        filter          = <<-EOT
          resource.type = "k8s_container"
          AND resource.labels.cluster_name = "${var.gke_cluster_name}"
          AND metric.type = "kubernetes.io/container/cpu/limit_utilization"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 0.90
        duration        = "900s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }

    gke_container_memory = {
      display_name  = "${var.name_prefix} container memory high"
      documentation = "Container memory limit utilization > 90% for 15m."
      combiner      = "OR"
      conditions = [{
        display_name    = "Container memory > 90%"
        filter          = <<-EOT
          resource.type = "k8s_container"
          AND resource.labels.cluster_name = "${var.gke_cluster_name}"
          AND metric.type = "kubernetes.io/container/memory/limit_utilization"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 0.90
        duration        = "900s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }

    gke_container_restarts = {
      display_name  = "${var.name_prefix} container restarts"
      documentation = "Container restart delta > 3 over 10m (possible crashloop)."
      combiner      = "OR"
      conditions = [{
        display_name    = "Restart count increasing"
        filter          = <<-EOT
          resource.type = "k8s_container"
          AND resource.labels.cluster_name = "${var.gke_cluster_name}"
          AND metric.type = "kubernetes.io/container/restart_count"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 3
        duration        = "600s"
        alignment       = "ALIGN_DELTA"
        align_period    = "300s"
      }]
    }

    cloudsql_cpu = {
      display_name  = "${var.name_prefix} Cloud SQL CPU high"
      documentation = "Cloud SQL CPU > 80% for 15m."
      combiner      = "OR"
      conditions = [{
        display_name    = "Cloud SQL CPU > 80%"
        filter          = <<-EOT
          resource.type = "cloudsql_database"
          AND resource.labels.database_id = "${var.project_id}:${var.cloudsql_instance_id}"
          AND metric.type = "cloudsql.googleapis.com/database/cpu/utilization"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 0.80
        duration        = "900s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }

    cloudsql_disk = {
      display_name  = "${var.name_prefix} Cloud SQL disk high"
      documentation = "Cloud SQL disk utilization > 85% for 15m."
      combiner      = "OR"
      conditions = [{
        display_name    = "Cloud SQL disk > 85%"
        filter          = <<-EOT
          resource.type = "cloudsql_database"
          AND resource.labels.database_id = "${var.project_id}:${var.cloudsql_instance_id}"
          AND metric.type = "cloudsql.googleapis.com/database/disk/utilization"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 0.85
        duration        = "900s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }

    cloudsql_connections = {
      display_name  = "${var.name_prefix} Cloud SQL connections high"
      documentation = "Cloud SQL connections > 80 for 10m (tune to your tier max_connections)."
      combiner      = "OR"
      conditions = [{
        display_name    = "Cloud SQL connections > 80"
        filter          = <<-EOT
          resource.type = "cloudsql_database"
          AND resource.labels.database_id = "${var.project_id}:${var.cloudsql_instance_id}"
          AND metric.type = "cloudsql.googleapis.com/database/network/connections"
        EOT
        comparison      = "COMPARISON_GT"
        threshold_value = 80
        duration        = "600s"
        alignment       = "ALIGN_MEAN"
        align_period    = "300s"
      }]
    }
  }
}

resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.notification_emails)

  project      = var.project_id
  display_name = "${var.name_prefix} email ${each.value}"
  type         = "email"
  labels = {
    email_address = each.value
  }
  user_labels = var.labels
}

resource "google_logging_metric" "backend_5xx" {
  project = var.project_id
  name    = "${replace(var.name_prefix, "-", "_")}_backend_5xx"
  filter  = <<-EOT
    resource.type="k8s_container"
    resource.labels.cluster_name="${var.gke_cluster_name}"
    resource.labels.container_name="backend"
    (jsonPayload.status>=500 OR httpRequest.status>=500)
  EOT
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

resource "google_monitoring_alert_policy" "this" {
  for_each = local.alert_policies

  project      = var.project_id
  display_name = each.value.display_name
  combiner     = each.value.combiner
  enabled      = true
  user_labels  = merge(var.labels, { alert = each.key })

  documentation {
    content   = each.value.documentation
    mime_type = "text/markdown"
  }

  dynamic "conditions" {
    for_each = each.value.conditions
    content {
      display_name = conditions.value.display_name
      condition_threshold {
        filter          = conditions.value.filter
        comparison      = conditions.value.comparison
        threshold_value = conditions.value.threshold_value
        duration        = conditions.value.duration
        aggregations {
          alignment_period   = conditions.value.align_period
          per_series_aligner = conditions.value.alignment
        }
        trigger {
          count = 1
        }
      }
    }
  }

  notification_channels = local.channel_ids

  alert_strategy {
    auto_close = "1800s"
  }
}

resource "google_monitoring_alert_policy" "backend_5xx" {
  project      = var.project_id
  display_name = "${var.name_prefix} backend 5xx rate"
  combiner     = "OR"
  enabled      = true
  user_labels  = merge(var.labels, { alert = "backend_5xx" })

  documentation {
    content   = "Backend container emitting HTTP 5xx events (log-based metric > 5 in 5m)."
    mime_type = "text/markdown"
  }

  conditions {
    display_name = "Backend 5xx"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.backend_5xx.name}\" AND resource.type=\"k8s_container\""
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      duration        = "300s"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
      }
      trigger {
        count = 1
      }
    }
  }

  notification_channels = local.channel_ids

  alert_strategy {
    auto_close = "1800s"
  }
}

resource "google_monitoring_dashboard" "overview" {
  count   = var.enable_dashboard ? 1 : 0
  project = var.project_id

  dashboard_json = jsonencode({
    displayName = "${var.name_prefix} platform overview"
    gridLayout = {
      columns = "2"
      widgets = [
        {
          title = "GKE node CPU"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"k8s_node\" AND resource.labels.cluster_name=\"${var.gke_cluster_name}\" AND metric.type=\"kubernetes.io/node/cpu/allocatable_utilization\""
                }
              }
            }]
          }
        },
        {
          title = "GKE node memory"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"k8s_node\" AND resource.labels.cluster_name=\"${var.gke_cluster_name}\" AND metric.type=\"kubernetes.io/node/memory/allocatable_utilization\""
                }
              }
            }]
          }
        },
        {
          title = "Cloud SQL CPU"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${var.project_id}:${var.cloudsql_instance_id}\" AND metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
                }
              }
            }]
          }
        },
        {
          title = "Cloud SQL connections"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${var.project_id}:${var.cloudsql_instance_id}\" AND metric.type=\"cloudsql.googleapis.com/database/network/connections\""
                }
              }
            }]
          }
        }
      ]
    }
  })
}
