output "notification_channel_ids" {
  value = local.channel_ids
}

output "alert_policy_names" {
  value = concat(
    [for k, v in google_monitoring_alert_policy.this : v.display_name],
    [google_monitoring_alert_policy.backend_5xx.display_name],
  )
}

output "dashboard_id" {
  value = try(google_monitoring_dashboard.overview[0].id, null)
}

output "backend_5xx_metric" {
  value = google_logging_metric.backend_5xx.name
}
