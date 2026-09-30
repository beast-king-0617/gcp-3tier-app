output "eso_service_account_email" {
  value = google_service_account.eso.email
}

output "cluster_secret_store_name" {
  value = "gcp-secret-manager"
}

output "namespace" {
  value = var.namespace
}
