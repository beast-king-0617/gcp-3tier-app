resource "google_service_account" "backend" {
  project      = var.project_id
  account_id   = "gke-backend"
  display_name = "GKE backend workload (${var.name_prefix})"
  description  = "Workload Identity SA for backend pods"
}

resource "google_service_account" "frontend" {
  project      = var.project_id
  account_id   = "gke-frontend"
  display_name = "GKE frontend workload (${var.name_prefix})"
  description  = "Workload Identity SA for frontend pods (minimal permissions)"
}

resource "google_service_account_iam_member" "backend_wi" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.backend_k8s_namespace}/${var.backend_k8s_service_account}]"
}

resource "google_service_account_iam_member" "frontend_wi" {
  service_account_id = google_service_account.frontend.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.frontend_k8s_namespace}/${var.frontend_k8s_service_account}]"
}

# Backend reads DB secrets from Secret Manager.
resource "google_secret_manager_secret_iam_member" "backend" {
  for_each = toset(var.secret_ids)

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend.email}"
}

# ESO controller SA will also need access — granted in external-secrets module when installed.
