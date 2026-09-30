locals {
  provider_attribute_condition = length(var.allowed_repositories) > 0 ? (
    format(
      "assertion.repository_owner == '%s' && (%s)",
      var.github_organization,
      join(" || ", [
        for repo in var.allowed_repositories :
        format("assertion.repository == '%s'", repo)
      ])
    )
    ) : (
    format("assertion.repository_owner == '%s'", var.github_organization)
  )
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = var.pool_display_name
  description               = var.pool_description
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = var.provider_display_name
  description                        = "GitHub Actions OIDC provider"
  disabled                           = false

  attribute_mapping   = var.attribute_mapping
  attribute_condition = local.provider_attribute_condition

  oidc {
    issuer_uri = var.issuer_uri
  }
}

resource "google_service_account_iam_member" "wif_impersonation" {
  for_each = var.service_account_bindings

  service_account_id = "projects/-/serviceAccounts/${each.value.service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member = format(
    "principalSet://iam.googleapis.com/%s/attribute.repository/%s",
    google_iam_workload_identity_pool.github.name,
    each.value.repository
  )
}
