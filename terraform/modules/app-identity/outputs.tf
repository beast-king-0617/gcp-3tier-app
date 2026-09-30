output "backend_service_account_email" {
  value = google_service_account.backend.email
}

output "frontend_service_account_email" {
  value = google_service_account.frontend.email
}

output "backend_wi_annotation" {
  description = "Value for iam.gke.io/gcp-service-account on the backend K8s ServiceAccount."
  value       = google_service_account.backend.email
}

output "frontend_wi_annotation" {
  value = google_service_account.frontend.email
}
