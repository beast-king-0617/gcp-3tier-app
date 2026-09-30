resource "google_secret_manager_secret" "this" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.key
  labels    = each.value.labels

  replication {
    dynamic "auto" {
      for_each = var.replication_auto ? [1] : []
      content {}
    }
  }
}

resource "google_secret_manager_secret_version" "this" {
  for_each = var.secrets

  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value.secret_data
}
