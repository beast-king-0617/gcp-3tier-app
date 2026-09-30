# ---------------------------------------------------------------------------
# Terraform remote state bucket (GCS)
#
# Features:
# - Uniform bucket-level access (no ACLs)
# - Versioning (state recovery / audit)
# - Public access prevention enforced
# - Soft delete retention for accidental deletes
# - Google-managed encryption (CMEK can be added later via KMS module)
# ---------------------------------------------------------------------------

resource "google_storage_bucket" "tfstate" {
  name                        = var.state_bucket_name
  project                     = var.shared_project_id
  location                    = var.state_bucket_location
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  storage_class               = "STANDARD"

  versioning {
    enabled = true
  }

  # Retain noncurrent versions for recovery; adjust for compliance needs.
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 50
      with_state         = "ARCHIVED"
    }
  }

  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  labels = local.labels

  depends_on = [module.shared_project_services]
}

# State access for environment Terraform service accounts.
resource "google_storage_bucket_iam_member" "tf_planner_state" {
  for_each = var.environments

  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tf_planner[each.key].email}"
}

resource "google_storage_bucket_iam_member" "tf_applier_state" {
  for_each = var.environments

  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tf_applier[each.key].email}"
}

# Break-glass human/group access (optional).
resource "google_storage_bucket_iam_member" "break_glass" {
  for_each = toset(var.break_glass_members)

  bucket = google_storage_bucket.tfstate.name
  role   = "roles/storage.objectAdmin"
  member = each.value
}
